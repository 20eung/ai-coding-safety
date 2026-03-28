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
if [ -f "$NOTES_FILE" ]; then
  RELEASE_NOTES=$(tail -n +3 "$NOTES_FILE")
  echo "📄 릴리즈 노트: $NOTES_FILE"
elif [ -f "CHANGELOG.md" ]; then
  CANONICAL_ESC=$(echo "$CANONICAL" | sed 's/\./\\./g')
  RELEASE_NOTES=$(awk "/^## ${CANONICAL_ESC} /{found=1; next} found && /^## /{exit} found{print}" CHANGELOG.md)
  echo "📄 릴리즈 노트: CHANGELOG.md 에서 추출"
else
  RELEASE_NOTES="Release $CANONICAL"
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
