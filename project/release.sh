#!/bin/bash
# ai-coding-safety — Release Script Template
# Runs version consistency check before creating a GitHub release.
#
# Usage:
#   bash scripts/release.sh              # auto-detect version
#   bash scripts/release.sh v1.2.3       # specify version

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# ── [CUSTOMIZE] Version source of truth ───────────────────────
VERSION_FILE="reports/dashboard/version.json"  # ← Change this

# ── Determine version ─────────────────────────────────────────
if [ -n "$1" ]; then
  CANONICAL="$1"
else
  EXT="${VERSION_FILE##*.}"
  if [ "$EXT" = "json" ]; then
    CANONICAL=$(python3 -c "
import json
d = json.load(open('$VERSION_FILE'))
v = d.get('version', '')
print(v if v.startswith('v') else 'v' + v)
" 2>/dev/null)
  else
    CANONICAL=$(cat "$VERSION_FILE" | tr -d '[:space:]')
  fi
fi

if [ -z "$CANONICAL" ]; then
  echo "❌ ERROR: 버전을 확인할 수 없습니다."
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 GitHub 릴리즈 준비: $CANONICAL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Run version consistency check ────────────────────────────
PROJECT_HOOK=".githooks/pre-push"
if [ -f "$PROJECT_HOOK" ]; then
  bash "$PROJECT_HOOK"
  if [ $? -ne 0 ]; then
    echo "❌ 버전 검사 실패 — 릴리즈를 중단합니다."
    exit 1
  fi
fi

# ── Check if release already exists ──────────────────────────
if gh release view "$CANONICAL" > /dev/null 2>&1; then
  echo "⚠️  $CANONICAL 릴리즈가 이미 존재합니다."
  read -p "   덮어쓰시겠습니까? (y/N): " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "   릴리즈를 취소합니다."
    exit 0
  fi
  gh release delete "$CANONICAL" --yes
fi

# ── Determine release notes ───────────────────────────────────
# [CUSTOMIZE] Adjust the release notes file path if needed.
NOTES_FILE="docs/release-notes/${CANONICAL}.md"
RELEASE_NOTES=""

if [ -f "$NOTES_FILE" ]; then
  RELEASE_NOTES=$(tail -n +3 "$NOTES_FILE")
  echo "📄 릴리즈 노트: $NOTES_FILE"
elif [ -f "CHANGELOG.md" ]; then
  CANONICAL_ESC=$(echo "$CANONICAL" | sed 's/\./\\./g')
  RELEASE_NOTES=$(awk "/^## ${CANONICAL_ESC} /{found=1; next} found && /^## /{exit} found{print}" CHANGELOG.md | sed '/^[[:space:]]*$/d')
  if [ -n "$RELEASE_NOTES" ]; then
    echo "📄 릴리즈 노트: CHANGELOG.md 에서 추출"
  fi
fi

# 릴리즈 노트가 없으면 작성 안내 후 중단
if [ -z "$RELEASE_NOTES" ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "❌ 릴리즈 노트가 없습니다 — 릴리즈를 중단합니다."
  echo ""
  echo "   아래 중 하나를 먼저 작성하세요:"
  echo ""
  echo "   A) 릴리즈 노트 파일 생성 (권장)"
  echo "      $NOTES_FILE"
  echo ""
  echo "   B) CHANGELOG.md에 항목 추가"
  echo "      ## $CANONICAL (YYYY-MM-DD) — 변경 내용 제목"
  echo "      - 변경 내용 1"
  echo "      - 변경 내용 2"
  echo ""
  echo "   작성 후 커밋하고 다시 실행하세요:"
  echo "   git add <파일> && git commit -m 'docs: $CANONICAL 릴리즈 노트 추가'"
  echo "   bash scripts/release.sh"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
fi

# ── [CUSTOMIZE] Release title ────────────────────────────────
TITLE="$CANONICAL"
if [ -f "$VERSION_FILE" ] && [[ "${VERSION_FILE##*.}" == "json" ]]; then
  DESC=$(python3 -c "import json; print(json.load(open('$VERSION_FILE')).get('description',''))" 2>/dev/null)
  [ -n "$DESC" ] && TITLE="$CANONICAL - $DESC"
fi

# ── Create GitHub release ─────────────────────────────────────
echo ""
echo "🚀 GitHub 릴리즈 생성 중..."
gh release create "$CANONICAL" --title "$TITLE" --notes "$RELEASE_NOTES"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 릴리즈 완료: $CANONICAL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
