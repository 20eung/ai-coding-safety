# 왜 Git 훅이 필요한가 — 바이브코더를 위한 설명

## AI와 함께 코딩할 때 생기는 문제

AI 코딩 어시스턴트(Claude, Gemini, Codex 등)와 함께 작업하면 코드 생성 속도가 극적으로 빨라집니다.
그런데 속도가 빨라진 만큼 **실수도 빠르게** 일어납니다.

가장 흔한 두 가지 사고:

### 사고 1: API 키 GitHub 노출

```python
# AI가 생성한 코드에 이런 게 들어있을 수 있습니다
TELEGRAM_KEY = "8585859981:AAEOTnOnk6qmBTOPrwYyVNaR-IY3Zwx6X7c"
```

이 상태로 `git commit` → `git push` 하면 GitHub에 공개됩니다.
GitHub에는 이런 패턴을 스캔하는 봇이 수천 개 돌아다닙니다.
**5분 안에 악용됩니다.**

### 사고 2: 버전 관리 불일치

릴리즈를 자주 하다 보면 `README.md`는 v5.2.6인데
대시보드는 v5.1.0, CHANGELOG는 v5.2.5인 상황이 생깁니다.
문서를 믿을 수 없게 되고, 나중에는 어떤 게 맞는지 본인도 모르게 됩니다.

---

## Git 훅이 해결하는 방법

Git 훅은 `git commit` 또는 `git push` 실행 시 **자동으로 실행되는 스크립트**입니다.

```
git commit  →  pre-commit 훅 실행  →  통과하면 커밋 / 실패하면 차단
git push    →  pre-push 훅 실행    →  통과하면 푸시 / 실패하면 차단
```

사람이 매번 확인하지 않아도 **시스템이 강제**합니다.

---

## 글로벌 훅 vs 프로젝트 훅

| | 글로벌 훅 | 프로젝트 훅 |
|---|---|---|
| 적용 범위 | 이 머신의 모든 저장소 | 이 프로젝트만 |
| 설치 위치 | `~/.githooks/` | `.githooks/` |
| 설정 | `git config --global core.hooksPath` | `git config core.hooksPath` |
| 용도 | 공통 보안 검사 | 프로젝트 전용 규칙 |
| GitHub 공유 | ❌ (머신 로컬) | ✅ (저장소에 포함) |

### 체이닝 구조

```
git push 실행
    ↓
~/.githooks/pre-push (글로벌)
    ↓
.githooks/pre-push 가 있으면 호출 (프로젝트)
    ↓
둘 다 통과해야 push 완료
```

---

## 한 줄 설치

```bash
# 글로벌 훅 (머신 전체 적용, 최초 1회)
bash <(curl -fsSL https://raw.githubusercontent.com/20eung/ai-coding-safety/main/scripts/install-global.sh)

# 프로젝트 훅 (프로젝트별, 프로젝트 루트에서 실행)
bash <(curl -fsSL https://raw.githubusercontent.com/20eung/ai-coding-safety/main/scripts/install-project.sh)
```
