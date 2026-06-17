#!/usr/bin/env python3
"""labyrinthos.co 메이저 아르카나 데이터 크롤링 및 seed SQL 생성 스크립트."""

from __future__ import annotations

import json
import re
import sys
import time
import urllib.request
from html.parser import HTMLParser
from pathlib import Path

from bs4 import BeautifulSoup
from deep_translator import GoogleTranslator

BASE_URL = "https://labyrinthos.co"
LIST_URL = f"{BASE_URL}/blogs/tarot-card-meanings-list"

# 기존 시드의 한글 카드명 유지
NAME_KO = {
    "The Fool": "바보",
    "The Magician": "마법사",
    "The High Priestess": "여사제",
    "The Empress": "여황제",
    "The Emperor": "황제",
    "The Hierophant": "교황",
    "The Lovers": "연인",
    "The Chariot": "전차",
    "Strength": "힘",
    "The Hermit": "은둔자",
    "Wheel of Fortune": "운명의 수레바퀴",
    "The Wheel of Fortune": "운명의 수레바퀴",
    "Justice": "정의",
    "The Hanged Man": "매달린 사람",
    "Death": "죽음",
    "Temperance": "절제",
    "The Devil": "악마",
    "The Tower": "탑",
    "The Star": "별",
    "The Moon": "달",
    "The Sun": "태양",
    "Judgement": "심판",
    "The World": "세계",
}

SLUG_TO_NUMBER = {
    "the-fool": 0,
    "the-magician": 1,
    "the-high-priestess": 2,
    "the-empress": 3,
    "the-emperor": 4,
    "the-hierophant": 5,
    "the-lovers": 6,
    "the-chariot": 7,
    "strength": 8,
    "the-hermit": 9,
    "the-wheel-of-fortune": 10,
    "justice": 11,
    "the-hanged-man": 12,
    "death": 13,
    "temperance": 14,
    "the-devil": 15,
    "the-tower": 16,
    "the-star": 17,
    "the-moon": 18,
    "the-sun": 19,
    "judgement": 20,
    "the-world": 21,
}


def fetch_html(url: str) -> str:
    req = urllib.request.Request(
        url,
        headers={"User-Agent": "SoulScriptReaderBot/1.0 (+local-dev)"},
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        return resp.read().decode("utf-8", errors="replace")


def slug_to_code(slug: str) -> str:
    return f"major_{SLUG_TO_NUMBER[slug]:02d}_{slug.replace('the-', '').replace('-', '_')}"


def extract_card_links(html: str) -> list[str]:
    pattern = re.compile(
        r"/blogs/tarot-card-meanings-list/([a-z0-9-]+)-meaning-major-arcana-tarot-card-meanings"
    )
    slugs: list[str] = []
    seen: set[str] = set()
    for match in pattern.finditer(html):
        slug = match.group(1)
        if slug in SLUG_TO_NUMBER and slug not in seen:
            seen.add(slug)
            slugs.append(slug)
    return sorted(slugs, key=lambda s: SLUG_TO_NUMBER[s])


def extract_image_url(soup: BeautifulSoup) -> str | None:
    tag = soup.find("meta", property="og:image:secure_url")
    if tag and tag.get("content"):
        return tag["content"]
    tag = soup.find("meta", property="og:image")
    if tag and tag.get("content"):
        url = tag["content"]
        return url.replace("http://", "https://")
    return None


def extract_title(soup: BeautifulSoup) -> str:
    h1 = soup.find("h1")
    if h1:
        title = h1.get_text(strip=True)
        title = re.sub(r"\s+Meaning.*$", "", title)
        return title.strip()
    og = soup.find("meta", property="og:title")
    if og and og.get("content"):
        return re.sub(r"\s+Meaning.*$", "", og["content"]).strip()
    return "Unknown"


def extract_section_text(soup: BeautifulSoup, heading_pattern: str) -> str:
    headings = soup.find_all(["h2", "h3"])
    start = None
    for h in headings:
        text = h.get_text(" ", strip=True)
        if re.search(heading_pattern, text, re.I):
            start = h
            break
    if start is None:
        return ""

    parts: list[str] = []
    for sibling in start.find_next_siblings():
        if sibling.name in {"h2", "h3"}:
            break
        if sibling.name == "table":
            continue
        if sibling.get("class") and any(
            c in {"product-grid", "newsletter", "shopify-section"}
            for c in sibling.get("class", [])
        ):
            break
        text = sibling.get_text(" ", strip=True)
        if not text:
            continue
        if "Join 2 million" in text or "Download App" in text:
            break
        if text.startswith("### "):
            continue
        parts.append(text)

    merged = " ".join(parts)
    merged = re.sub(r"\s+", " ", merged).strip()
    return merged


def translate_to_korean(text: str, translator: GoogleTranslator) -> str:
    if not text:
        return ""
    # 긴 텍스트는 문장 단위로 분할 번역
    chunks: list[str] = []
    sentences = re.split(r"(?<=[.!?])\s+", text)
    buffer = ""
    for sentence in sentences:
        candidate = f"{buffer} {sentence}".strip() if buffer else sentence
        if len(candidate) > 4500:
            if buffer:
                chunks.append(translator.translate(buffer))
            buffer = sentence
        else:
            buffer = candidate
    if buffer:
        chunks.append(translator.translate(buffer))
    return " ".join(chunks).strip()


def sql_escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace("'", "''")


def build_sql(cards: list[dict]) -> str:
    lines = [
        "USE soul_script_reader;",
        "",
        "-- labyrinthos.co 에서 수집한 메이저 아르카나 22장 시드 데이터",
        "DELETE FROM draw_history;",
        "DELETE FROM tarot_cards;",
        "",
        "INSERT INTO tarot_cards (code, name_en, name_ko, arcana, number, image_url, meaning_upright, meaning_reversed) VALUES",
    ]

    values = []
    for card in cards:
        values.append(
            "('{code}', '{name_en}', '{name_ko}', 'major', {number}, '{image_url}',\n"
            " '{meaning_upright}',\n"
            " '{meaning_reversed}')".format(
                code=sql_escape(card["code"]),
                name_en=sql_escape(card["name_en"]),
                name_ko=sql_escape(card["name_ko"]),
                number=card["number"],
                image_url=sql_escape(card["image_url"]),
                meaning_upright=sql_escape(card["meaning_upright"]),
                meaning_reversed=sql_escape(card["meaning_reversed"]),
            )
        )

    lines.append(",\n".join(values) + ";")
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    output_sql = Path(__file__).resolve().parents[1] / "sql" / "seed_major_arcana.sql"
    output_json = Path(__file__).resolve().parents[1] / "sql" / "seed_major_arcana.json"

    print("목록 페이지 크롤링...", file=sys.stderr)
    list_html = fetch_html(LIST_URL)
    slugs = extract_card_links(list_html)
    if len(slugs) != 22:
        print(f"경고: 메이저 아르카나 {len(slugs)}장 발견 (22장 예상)", file=sys.stderr)

    translator = GoogleTranslator(source="en", target="ko")
    cards: list[dict] = []

    for index, slug in enumerate(slugs, start=1):
        url = f"{LIST_URL}/{slug}-meaning-major-arcana-tarot-card-meanings"
        print(f"[{index}/22] {slug} ...", file=sys.stderr)
        html = fetch_html(url)
        soup = BeautifulSoup(html, "html.parser")

        name_en = extract_title(soup)
        image_url = extract_image_url(soup) or ""
        upright_en = extract_section_text(soup, r"Upright\s+.*\s+Meaning")
        reversed_en = extract_section_text(soup, r"Reversed\s+.*\s+Meaning")

        if not upright_en:
            upright_en = extract_section_text(soup, r"Upright")
        if not reversed_en:
            reversed_en = extract_section_text(soup, r"Reversed")

        upright_ko = translate_to_korean(upright_en, translator)
        time.sleep(0.3)
        reversed_ko = translate_to_korean(reversed_en, translator)
        time.sleep(0.3)

        cards.append(
            {
                "code": slug_to_code(slug),
                "name_en": name_en,
                "name_ko": NAME_KO.get(name_en, name_en),
                "number": SLUG_TO_NUMBER[slug],
                "image_url": image_url,
                "meaning_upright": upright_ko,
                "meaning_reversed": reversed_ko,
                "source_url": url,
            }
        )

    output_json.write_text(json.dumps(cards, ensure_ascii=False, indent=2), encoding="utf-8")
    output_sql.write_text(build_sql(cards), encoding="utf-8")
    print(f"생성 완료: {output_sql}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
