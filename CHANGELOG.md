## v1.1.0 - 2026-03-28

### Added
- `.githooks/pre-commit` — 프로젝트 전용 보안 검사 훅 (파일/패턴 커스터마이징 가능)
- `.githooks/pre-push` — 버전 일관성 검사 훅 (VERSION_FILE 커스터마이징 가능)
- `scripts/install-hooks.sh` — 다른 프로젝트에 훅을 설치하는 스크립트
- `scripts/release.sh` — 버전 일관성 검사 후 GitHub 릴리즈 생성 스크립트

### Global Hooks
- `~/.githooks/pre-commit` — 모든 저장소에서 민감 정보 차단 (API 키, .env, 개인키 등)
- `~/.githooks/pre-push` — 프로젝트 훅으로 체이닝
