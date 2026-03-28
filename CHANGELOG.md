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
