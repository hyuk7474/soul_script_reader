-- Soul Script Reader 데이터베이스 스키마

CREATE DATABASE IF NOT EXISTS soul_script_reader
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE soul_script_reader;

-- 카드 마스터 (메이저 아르카나 22장 + 확장 가능)
CREATE TABLE IF NOT EXISTS tarot_cards (
  id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code              VARCHAR(32) NOT NULL UNIQUE COMMENT 'e.g. major_00_fool',
  name_en           VARCHAR(64) NOT NULL,
  name_ko           VARCHAR(64) NOT NULL,
  arcana            ENUM('major', 'minor') NOT NULL DEFAULT 'major',
  suit              VARCHAR(16) NULL COMMENT 'cups, wands, swords, pentacles',
  number            TINYINT UNSIGNED NULL,
  image_url         VARCHAR(512) NULL,
  meaning_upright   TEXT NOT NULL,
  meaning_reversed  TEXT NOT NULL,
  created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_arcana (arcana)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 뽑기 히스토리
CREATE TABLE IF NOT EXISTS draw_history (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  card_id       INT UNSIGNED NOT NULL,
  is_reversed   TINYINT(1) NOT NULL DEFAULT 0,
  drawn_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  note          VARCHAR(255) NULL,
  FOREIGN KEY (card_id) REFERENCES tarot_cards(id) ON DELETE RESTRICT,
  INDEX idx_drawn_at (drawn_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
