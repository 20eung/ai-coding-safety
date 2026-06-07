#!/bin/bash
# ai-coding-safety — Release Script Template
# Runs version consistency check before creating a GitHub release.
#
# Usage:
#   bash scripts/release.sh              # auto-detect version
#   bash scripts/release.sh v1.2.3       # specify version
#   bash scripts/release.sh v1.2.3 -f   # force overwrite existing release

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# ── Parse arguments ───────────────────────────────────────────
FORCE_OVERWRITE=false
VERSION_ARG=""
for arg in "$@"; do
  if [ "$arg" = "-f" ] || [ "$arg" = "--force" ]; then
    FORCE_OVERWRITE=true
  elif [[ "$arg" == v* ]]; then
    VERSION_ARG="$arg"
  fi
done

# ── Version source of truth ───────────────────────────────────
VERSION_FILE="version.json"

# ── Determine version ─────────────────────────────────────────
if [ -n "$VERSION_ARG" ]; then
  CANONICAL="$VERSION_ARG"
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

# ── Intelligent Version & Changelog Analysis ──────────────────
HELPER_RESULT=$(python3 scripts/release_helper.py "$VERSION_ARG")
NEXT_VERSION=$(echo "$HELPER_RESULT" | python3 -c "import sys, json; print(json.load(sys.stdin)['next_version'])")
LATEST_TAG=$(echo "$HELPER_RESULT" | python3 -c "import sys, json; print(json.load(sys.stdin)['latest_tag'])")
BUMP_TYPE=$(echo "$HELPER_RESULT" | python3 -c "import sys, json; print(json.load(sys.stdin)['bump_type'])")
CHANGELOG_ENTRY=$(echo "$HELPER_RESULT" | python3 -c "import sys, json; print(json.load(sys.stdin)['changelog_entry'])")
HAS_COMMITS=$(echo "$HELPER_RESULT" | python3 -c "import sys, json; print(str(json.load(sys.stdin)['has_commits']).lower())")

# If version from version.json equals latest tag, we MUST bump
if [ -z "$VERSION_ARG" ] && [ "$CANONICAL" = "$LATEST_TAG" ]; then
  if [ "$HAS_COMMITS" = "true" ]; then
    echo "🤖 AI가 커밋 로그를 분석하여 버전을 자동으로 결정했습니다: $BUMP_TYPE ($CANONICAL -> $NEXT_VERSION)"
    CANONICAL="$NEXT_VERSION"
    DO_BUMP=true
  else
    echo "⚠️  이전 릴리즈 이후 새로운 커밋이 없습니다."
    if [ -t 0 ]; then
      read -p "   그래도 진행하시겠습니까? (y/N): " -n 1 -r
      echo ""
      [[ ! $REPLY =~ ^[Yy]$ ]] && echo "   릴리즈를 취소합니다." && exit 0
    else
      echo "   비대화형 환경에서는 자동 취소합니다. --force 옵션으로 강제 진행 가능."
      exit 0
    fi
    DO_BUMP=false
  fi
elif [ -n "$VERSION_ARG" ] && [ "$VERSION_ARG" != "$LATEST_TAG" ]; then
  # Explicit version provided as argument
  CANONICAL="$VERSION_ARG"
  DO_BUMP=true
else
  DO_BUMP=false
fi

if [ "$DO_BUMP" = true ]; then
  echo "🚀 버전을 $CANONICAL 로 업데이트하고 문서를 동기화합니다..."
  
  # Update version.json
  python3 -c "
import json, sys
data = json.load(open('$VERSION_FILE'))
data['version'] = '$CANONICAL'
with open('$VERSION_FILE', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
"
  
  # Update README files
  PREV_V_PLAIN="${LATEST_TAG#v}"
  NEW_V_PLAIN="${CANONICAL#v}"
  LATEST_TAG_ESC=$(echo "$LATEST_TAG" | sed 's/\./\\./g')
  PREV_V_ESC=$(echo "$PREV_V_PLAIN" | sed 's/\./\\./g')
  sed -i "s/# ai-coding-safety ${LATEST_TAG_ESC}/# ai-coding-safety ${CANONICAL}/g" README.md
  sed -i "s/Version-${PREV_V_ESC}-blueviolet/Version-${NEW_V_PLAIN}-blueviolet/g" README.md
  [ -f README.en.md ] && sed -i "s/# ai-coding-safety ${LATEST_TAG_ESC}/# ai-coding-safety ${CANONICAL}/g" README.en.md
  [ -f README.en.md ] && sed -i "s/Version-${PREV_V_ESC}-blueviolet/Version-${NEW_V_PLAIN}-blueviolet/g" README.en.md

  # Update CHANGELOG.md (Prepend automated entry)
  if [ -f CHANGELOG.md ]; then
    (printf '%s\n' "$CHANGELOG_ENTRY"; cat CHANGELOG.md) > CHANGELOG.md.new
  else
    printf '%s\n' "$CHANGELOG_ENTRY" > CHANGELOG.md.new
  fi
  mv CHANGELOG.md.new CHANGELOG.md

  # Commit changes (only existing files)
  git add "$VERSION_FILE" README.md CHANGELOG.md
  [ -f README.en.md ] && git add README.en.md
  git commit -m "chore: version $CANONICAL bump (automated)"
  git push origin "$(git rev-parse --abbrev-ref HEAD)"
  
  echo "✅ 버전 업데이트 및 푸시 완료: $CANONICAL"
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 GitHub 릴리즈 준비: $CANONICAL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Run version consistency check ────────────────────────────
PROJECT_HOOK=".githooks/pre-push"
if [ -f "$PROJECT_HOOK" ]; then
  bash "$PROJECT_HOOK" || { echo "❌ 버전 검사 실패 — 릴리즈를 중단합니다."; exit 1; }
fi

# ── Check if release already exists (for overwrite case) ────────
if gh release view "$CANONICAL" > /dev/null 2>&1; then
  if [ "$FORCE_OVERWRITE" != "true" ]; then
    echo "⚠️  $CANONICAL 릴리즈가 이미 존재합니다."
    if [ -t 0 ]; then
      read -p "   덮어쓰시겠습니까? (y/N): " -n 1 -r
      echo ""
      [[ ! $REPLY =~ ^[Yy]$ ]] && echo "   릴리즈를 취소합니다." && exit 0
    else
      echo "   비대화형 환경에서는 자동 취소합니다. -f 옵션으로 강제 덮어쓰기 가능."
      exit 0
    fi
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
  if [ -n "$RELEASE_NOTES" ]; then
    echo "📄 릴리즈 노트: CHANGELOG.md 에서 추출"
  fi
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
