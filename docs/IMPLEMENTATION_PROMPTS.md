# Soul Script Reader — 단계별 구현 프롬프트

> Cursor Agent에 **한 단계씩** 붙여 넣어 실행하세요.  
> 각 프롬프트는 토큰 한도를 고려해 범위를 제한했습니다.  
> 설계 상세: [`DESIGN.md`](./DESIGN.md)

---

## 사용 방법

1. 프로젝트 루트: `soul_script_reader` (Flutter)
2. 단계 **1 → 2 → 3-A → 3-B → 3-C → 3-D** 순서 고정
3. 각 단계 완료 후 `flutter analyze` 실행
4. 이전 단계에서 만든 파일·경로를 **삭제·이름 변경하지 말 것**

---

## 단계 1 — 전체 앱 구조 (골격만)

**목표**: 클린 아키텍처 폴더, 라우터, 테마, 빈 화면 4개. 비즈니스 로직·API 없음.

```
다음 요구사항으로 Flutter 프로젝트 soul_script_reader의 앱 골격만 만들어줘.
상세 설계는 docs/DESIGN.md를 읽고 따른다.

【범위 — 이 단계에서만】
- pubspec.yaml에 추가: go_router, flutter_riverpod, flutter_dotenv
- lib/ 아래 DESIGN.md 4절 폴더 구조 생성 (domain/data는 빈 export 또는 placeholder만)
- app/app.dart, app/router/app_router.dart, app/theme/app_theme.dart
- presentation: splash, main, draw, history — 각각 Screen 위젯만 (Placeholder 텍스트)
- main.dart: ProviderScope, dotenv 로드, MaterialApp.router
- 라우트: / → Splash, /main, /draw, /history
- 다크 테마 (Primary #2D1B4E, Accent #C9A227, Background #0F0A1A)
- 기존 counter 데모 코드는 제거

【하지 말 것】
- Entity, Repository, API, MySQL, UseCase 구현
- 복잡한 UI/애니메이션

【완료 조건】
- flutter analyze 통과
- 앱 실행 시 Splash → (수동 또는 임시 버튼으로) 각 라우트 이동 가능

파일 생성 목록을 마지막에 요약해줘.
```

---

## 단계 2 — 클린 아키텍처 (도메인 + 데이터 + Provider)

**목표**: Entity, Model, DataSource, Repository, UseCase, Riverpod Provider, MySQL 스키마·API 스텁.

```
단계 1에서 만든 soul_script_reader 골격 위에 클린 아키텍처 레이어를 구현해줘.
docs/DESIGN.md의 4~7절, MySQL 스키마(5절), REST API(6절)를 따른다.

【범위 — 이 단계에서만】

1) domain/
   - entities: TarotCard, DrawRecord, DrawResult
   - repositories (abstract): TarotRepository, HistoryRepository
   - usecases: DrawRandomCard, SaveDrawHistory, GetDrawHistory, GetTarotCardById

2) data/
   - models + fromJson/toJson (freezed+json_serializable 사용 가능)
   - tarot_remote_datasource, history_remote_datasource (Dio, DESIGN API 경로)
   - repository_impl 2개

3) core/
   - failures/exceptions, dio_client (Base URL은 dotenv API_BASE_URL)
   - constants: api_paths.dart

4) presentation/providers/
   - repository·usecase Provider 등록

5) server/ (신규)
   - sql/schema.sql, sql/seed_major_arcana.sql (메이저 22장 최소 3~5장 샘플도 OK, 전체 22장 권장)
   - server/README.md: MySQL 실행·API 실행 방법 간단히

6) API 스텁
   - server/에 Dart shelf 또는 Node Express 중 하나로 최소 엔드포인트 구현:
     GET /api/v1/cards/random, GET /api/v1/history, POST /api/v1/history
   - MySQL 8.4 LTS 연동 (mysql_client_plus)

7) pubspec: dio, freezed_annotation, json_annotation, dev: build_runner, freezed, json_serializable

【하지 말 것】
- Splash/Main/Draw/History 화면 UI 상세 구현 (placeholder 유지)
- 카드 플립 애니메이션

【완료 조건】
- API 서버 로컬 기동 시 UseCase 단위로 random draw / history save·list가 동작
- flutter analyze 통과
- .env.example 추가 (API_BASE_URL)

변경·추가 파일 목록을 요약해줘.
```

---

## 단계 3-A — Splash 페이지

**목표**: Splash UI + 초기화 + 자동 메인 이동.

```
단계 1~2가 적용된 soul_script_reader에서 Splash 화면만 완성해줘.
docs/DESIGN.md 8.1절 참고.

【범위】
- lib/presentation/splash/ — splash_page.dart, 필요 시 splash_controller (Riverpod)
- UI: 앱 타이틀 "Soul Script Reader", 서브 카피, 로딩 인디케이터, 다크+골드 테마
- AppInitializer: dotenv 이미 로드됨 가정, optional Dio health GET (실패해도 3초 후 진행 가능)
- 2~3초 후 context.go('/main') — post-frame 또는 Future.delayed
- app_router: initialLocation '/' 유지

【하지 말 것】
- main, draw, history 페이지 수정 (필요 시 import만)

【완료 조건】
- 앱 cold start → Splash → 자동으로 Main

다른 페이지는 건드리지 않았는지 명시해줘.
```

---

## 단계 3-B — 메인 페이지

**목표**: 메인 화면 + 두 버튼 네비게이션.

```
soul_script_reader의 메인 페이지만 구현해줘. docs/DESIGN.md 8.2절.

【범위】
- lib/presentation/main/main_page.dart
- AppBar: 앱 이름
- 버튼 2개: 「카드 뽑기」→ context.push('/draw'), 「카드 내역」→ context.push('/history')
- 공통 위젯이 있으면 presentation/common/widgets 재사용
- 테마·패딩·접근성(최소 터치 영역 48) 준수

【하지 말 것】
- draw, history, splash 로직 변경

【완료 조건】
- Main에서 두 화면으로 이동 후 뒤로가기 정상

수정한 파일만 나열해줘.
```

---

## 단계 3-C — 카드 뽑기 페이지

**목표**: 랜덤 뽑기, 해석 표시, 히스토리 저장.

```
soul_script_reader의 카드 뽑기(/draw) 페이지만 구현해줘. docs/DESIGN.md 8.3절, UseCase는 단계 2 Provider 사용.

【범위】
- draw_page.dart + draw_notifier (AsyncNotifier 또는 StateNotifier)
- 상태: idle → drawing → revealed → saving → saved / error
- 「카드 뽑기」: DrawRandomCard 호출, 간단한 플립 또는 페이드 애니메이션
- revealed: name_ko, 정/역 뱃지, meaning_upright/reversed 텍스트
- 「히스토리에 저장」: SaveDrawHistory
- 「다시 뽑기」「내역 보기」 버튼
- 로딩·에러 UI (core/errors 메시지 friendly)

【하지 말 것】
- history 목록 UI 전체 구현
- splash, main 대규모 수정

【완료 조건】
- 뽑기 → 저장 → 스낵바 성공
- API 없을 때 에러 UI 표시

수정 파일 목록 + 수동 테스트 절차 3줄로 정리해줘.
```

---

## 단계 3-D — 카드 내역 페이지

**목표**: 히스토리 목록·상세·새로고침.

```
soul_script_reader의 카드 내역(/history) 페이지만 구현해줘. docs/DESIGN.md 8.4절.

【범위】
- history_page.dart + history_notifier
- GetDrawHistory로 목록 로드, RefreshIndicator
- ListTile: drawn_at(intl 포맷), name_ko, 정/역
- 탭 시 showModalBottomSheet 또는 Dialog로 해석 전문 표시
- 빈 목록 empty state
- draw 페이지에서 저장 후 history 왔을 때 목록 갱신(ref.invalidate 등)

【하지 말 것】
- draw/splash/main 재작성

【완료 조건】
- 저장된 기록이 최신순 표시
- pull-to-refresh 동작

수정 파일 목록해줘.
```

---

## (선택) 단계 4 — 통합·README·마무리

토큰 여유가 있을 때 한 번에 실행.

```
soul_script_reader 포트폴리오 마무리해줘.

【범위】
- README.md: 앱 소개, 스크린샷 placeholder, DB 마이그레이션, API 실행, flutter run, .env 설정
- .gitignore에 .env, server/.env 확인
- flutter analyze / test/widget_test.dart 스모크 테스트 1개(앱 부팅)
- DESIGN.md 13절 체크리스트 기준으로 누락 항목 보완

【하지 말 것】
- 대규모 리팩터링, 디자인 전면 변경
```

---

## 프롬프트 실행 체크리스트

| 단계 | 실행 전 확인 | 실행 후 |
|------|--------------|---------|
| 1 | Flutter SDK 설치 | 4라우트 빈 화면 |
| 2 | MySQL 8.4 LTS 로컬 설치 (`brew install mysql@8.4`) | API + schema.sql |
| 3-A | 단계 2 완료 | Splash → Main 자동 |
| 3-B | 3-A 완료 | Main 버튼 2개 |
| 3-C | API 기동 | 뽑기·저장 |
| 3-D | 히스토리 데이터 있음 | 목록·상세 |

---

## 트러블슈팅 (프롬프트에 붙일 수 있는 한 줄)

- Android 에뮬레이터 API: `API_BASE_URL=http://10.0.2.2:8080`
- iOS 시뮬레이터: `http://127.0.0.1:8080`
- MySQL 연결 실패: `server/README.md`의 계정·DB 생성 확인

---

*프롬프트 문서 버전: 1.0*
