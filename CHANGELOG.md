## v1.2.2 (2026-03-28)

- 

---

## v1.2.1 (2026-03-28)

- 

---

## v1.2.0 (2026-03-28) — 릴리즈 노트 자동 생성 + 버전 관리 체계 도입

## 버그 수정
- `project/release.sh`: 릴리즈 노트 없을 때 git log 기반 자동 생성
  - `feat/fix/docs/chore` prefix별 섹션 자동 분류
  - `docs/release-notes/vX.Y.Z.md` + `CHANGELOG.md` 자동 생성 후 커밋

## 기타
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
