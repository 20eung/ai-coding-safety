# 프로젝트별 커스터마이징 가이드

## pre-commit 커스터마이징

`.githooks/pre-commit` 파일에서 `[CUSTOMIZE]` 표시된 섹션을 수정합니다.

### 특정 파일 커밋 차단

```bash
BLOCKED_FILES=(
  "config/config.yaml"      # KIS API 키 포함
  "config/secrets.json"     # 시크릿 파일
  ".env.production"         # 운영 환경 변수
)
```

### 프로젝트 전용 API 키 패턴 추가

```bash
PATTERNS=(
  # KIS 증권사 API 키 (PS로 시작, 32자 이상)
  "app_key.*['\"]PS[a-zA-Z0-9]{30,}['\"]"

  # 사내 서비스 토큰
  "internal_token.*['\"][a-zA-Z0-9]{40,}['\"]"
)
```

---

## pre-push 커스터마이징

`.githooks/pre-push` 파일에서 `[CUSTOMIZE]` 표시된 섹션을 수정합니다.

### 버전 파일 경로 설정

```bash
# JSON 파일 (version 필드)
VERSION_FILE="reports/dashboard/version.json"

# package.json
VERSION_FILE="package.json"

# 일반 텍스트
VERSION_FILE="VERSION"
```

### 버전 검사 파일 추가

```bash
# README.md 제목 검사
check "README.md" "${CANONICAL}" "README 버전 표기"

# 뱃지 검사
check "README.md" "Version-${CANONICAL_PLAIN}-blueviolet" "버전 뱃지"

# CHANGELOG 최신 항목
check "CHANGELOG.md" "^## ${CANONICAL} " "CHANGELOG 최신 항목"

# 특정 문서
check "docs/GUIDE.md" "\(${CANONICAL}\)" "가이드 버전"
```

---

## 버전 파일 포맷별 설정 예시

### Node.js 프로젝트 (package.json)

```bash
VERSION_FILE="package.json"
# pre-push 훅이 자동으로 "version" 필드를 읽습니다
```

### Python 프로젝트

```bash
VERSION_FILE="pyproject.toml"
# 또는
VERSION_FILE="src/__version__.py"
```

`pre-push` 훅의 버전 읽기 로직을 해당 포맷에 맞게 수정하세요.

### 커스텀 버전 파일

```bash
VERSION_FILE="VERSION"
# 파일 내용: v1.2.3 (한 줄)
```

---

## AI에게 커스터마이징 요청하는 방법

훅 설치 후 AI에게 이렇게 말하면 됩니다:

```
".githooks/pre-commit 에서 config/config.yaml 커밋을 차단하게 해줘"
".githooks/pre-push 에서 README.md와 CHANGELOG.md 버전 검사를 추가해줘"
```
