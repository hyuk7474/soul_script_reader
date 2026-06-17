# Soul Script Reader API 서버

Dart `shelf` + `mysql_client_plus` 기반 REST API 서버입니다.

## 사전 준비

- Dart SDK 3.10+
- MySQL 8.4 LTS (Homebrew: `brew install mysql@8.4`)

```bash
# MySQL 8.4 LTS 설치 및 시작 (macOS Homebrew)
brew install mysql@8.4
brew link mysql@8.4 --force
brew services start mysql@8.4
```

> **버전 안내**: Homebrew에 제공되는 LTS는 `mysql@8.4`입니다. `brew install mysql`(9.x)는 Innovation 릴리스이므로 본 프로젝트에서는 사용하지 않습니다.

## 1. MySQL 설정

```bash
# MySQL 접속 후 사용자·DB 생성 (예시)
mysql -u root -p

CREATE USER 'soul_app'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON soul_script_reader.* TO 'soul_app'@'localhost';
FLUSH PRIVILEGES;
```

```bash
# 스키마 및 시드 데이터 적용
mysql -u root -p < sql/schema.sql
mysql -u root -p < sql/seed_major_arcana.sql
```

## 2. 환경 변수

```bash
cd server
cp .env.example .env
# .env 파일에서 MYSQL_PASSWORD 등 수정
```

## 3. API 서버 실행

```bash
cd server
dart pub get
dart run bin/server.dart
```

서버가 `http://127.0.0.1:8080` 에서 실행됩니다.

## API 엔드포인트

| Method | Path | 설명 |
|--------|------|------|
| GET | `/health` | 헬스 체크 |
| GET | `/api/v1/cards/random` | 랜덤 카드 1장 + 정/역 |
| GET | `/api/v1/cards/:id` | 카드 상세 |
| GET | `/api/v1/history?limit=50&offset=0` | 히스토리 목록 |
| POST | `/api/v1/history` | 히스토리 저장 |

### POST /api/v1/history 예시

```json
{
  "card_id": 1,
  "is_reversed": false,
  "note": "오늘의 카드"
}
```

## Flutter 앱 연동

프로젝트 루트 `.env`:

```env
API_BASE_URL=http://127.0.0.1:8080
```

- Android 에뮬레이터: `http://10.0.2.2:8080`
- iOS 시뮬레이터: `http://127.0.0.1:8080`
