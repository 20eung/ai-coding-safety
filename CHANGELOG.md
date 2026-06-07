## v1.5.0 (2026-06-08)

- (No specific changes found in git log)

---
# CHANGELOG

## v1.4.0 (2026-06-07)

### 🐛 Bug Fixes
- fix: global/pre-commit SECRET_FILES `$(` 문법 오류 수정 (토큰 파일 검사 비동작 버그)
- fix: scripts/release.sh `$BUMP` 미정의 변수 → `$DO_BUMP`로 수정 (기존 릴리즈 덮어쓰기 오동작)
- fix: scripts/release.sh 오타 수정 ("릴지즈" → "릴리즈")
- fix: global/pre-commit + project/pre-commit CI 비대화형 환경 `read -p` hang 수정 (TTY 감지 자동 차단)

### ✨ New Features
- feat: global/pre-commit 보안 패턴 추가 — Google/Gemini, Stripe, HuggingFace, OpenAI Project Key(sk-proj-), GitHub Fine-grained PAT
- feat: global/pre-push main/master 직접 push 경고 추가 (대화형 확인)
- feat: scripts/release_helper.py perf/test/ci/build prefix 별도 분류 및 이모지 구분

### 🔧 CI / Build
- refactor: scripts/install-hooks.sh install-project.sh 래퍼로 중복 제거
- chore: scripts/install-project.sh release_helper.py 다운로드 자동 추가
- chore: .gitignore 신규 생성 (.bkit/ 제외)

### 🔩 Others
- refactor: project/pre-push VERSION_FILE 기본값 수정 (`reports/dashboard/version.json` → `version.json`)
- refactor: project/release.sh VERSION_FILE 기본값 수정

### 📝 Documentation
- docs: README.md 긴급 우회(--no-verify) 섹션 및 목차 추가
- docs: docs/why-hooks.md --no-verify 안내 추가
- docs: docs/customization.md pyproject.toml 미지원 명시 및 대안 안내
- docs: AGENTS.md Step 5 staged 파일 없이 훅 실제 검증하는 방법 보완

---
## v1.3.2 (2026-03-28)

### 📝 Documentation
- docs: AI 릴리즈 절차 강제화 (AGENTS.md, CLAUDE.md, GEMINI.md)

---
## v1.3.1 (2026-03-28)

### 🐛 Bug Fixes
- fix: release.sh 불리언 비교 로직 수정 (Bash 호환성)

### 📝 Documentation
- docs: 실질적인 최종 배포 완료
- docs: 버전 일관성 검사 섹션 및 시각적 예시 추가

---
## v1.3.0 (2026-03-28)

### ✨ New Features
- feat: 지능형 자동 릴리즈 시스템 (SemVer 분석 및 릴리즈 노트 자동 생성)

### 📝 Documentation
- docs: 자동 릴리즈 테스트를 위한 공백 추가
- docs: CHANGELOG.md v1.2.1, v1.2.2 누락된 내용 보완

---
## v1.2.2 (2026-03-28)

- README 시각적 오류 (ANSI escape code 노출) 해결
- 명칭 순화 및 일관성 확보 ("보고" -> "참고해서", "머신" -> "컴퓨터")
- `scripts/release.sh` 버전 업그레이드 미리보기 동적 표시 기능 추가 (Bug Fix)

---

## v1.2.1 (2026-03-28)

- `scripts/release.sh` 자동 버전 업그레이드 및 문서 연동 로직 추가
- `version.json`, `README.md`, `README.en.md`, `CHANGELOG.md` 버전 자동 동기화 기능 도입
- GitHub 최신 릴리즈 감지 및 중복 버전 처리 정책(Patch/Minor/Major) 추가

---

## v1.2.0 (2026-03-28) — 릴리즈 노트 자동 생성 + 버전 관리 체계 도입

### 버그 수정
- `project/release.sh`: 릴리즈 노트 없을 때 git log 기반 자동 생성
  - `feat/fix/docs/chore` prefix별 섹션 자동 분류
  - `docs/release-notes/vX.Y.Z.md` + `CHANGELOG.md` 자동 생성 후 커밋

### 기타
- `version.json` 도입 — 버전 단일 소스 (SSOT)
- `README.md` 버전 뱃지 추가
- `.githooks/pre-push` 버전 검사 활성화 (`version.json` 기준)
- `scripts/release.sh` `VERSION_FILE` 경로 `version.json`으로 설정

---

## v1.1.0 (2026-03-28)

### 추가된 기능
- `.githooks/pre-commit` — 프로젝트 전용 보안 검사 훅 (파일/패턴 커스터마이징 가능)
- `.githooks/pre-push` — 버전 일관성 검사 훅 (VERSION_FILE 커스터마이징 가능)
- `scripts/install-hooks.sh` — 다른 프로젝트에 훅을 설치하는 스크립트
- `scripts/release.sh` — 버전 일관성 검사 후 GitHub 릴리즈 생성 스크립트

### 글로벌 훅
- `~/.githooks/pre-commit` — 모든 저장소에서 민감 정보 차단 (API 키, .env, 개인키 등)
- `~/.githooks/pre-push` — 프로젝트 훅으로 체이닝
