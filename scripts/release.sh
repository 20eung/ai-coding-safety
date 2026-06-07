#!/bin/bash
# ai-coding-safety — Release Script
# version.json 에서 버전을 읽어 GitHub 릴리즈를 생성합니다.
#
# Usage:
#   bash scripts/release.sh              # version.json 에서 자동 감지
#   bash scripts/release.sh v1.2.3       # 버전 직접 지정
#   bash scripts/release.sh v1.2.3 -f   # 기존 릴리즈 덮어쓰기

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# ── Parse arguments ────────────────────────────────────────────
FORCE=false
VERSION_ARG=""
for arg in "$@"; do
  if [ "$arg" = "-f" ] || [ "$arg" = "--force" ]; then
    FORCE=true
  elif [[ "$arg" == v* ]]; then
    VERSION_ARG="$arg"
  fi
done

# ── Determine version ──────────────────────────────────────────
VERSION_FILE="version.json"

if [ -n "$VERSION_ARG" ]; then
  CANONICAL="$VERSION_ARG"
else
  CANONICAL=$(python3 -c "
import json
d = json.load(open('$VERSION_FILE'))
v = d.get('version', '')
print(v if v.startswith('v') else 'v' + v)
" 2>/dev/null)
fi

if [ -z "$CANONICAL" ]; then
  echo "❌ 버전을 확인할 수 없습니다. ($VERSION_FILE)"
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 GitHub 릴리즈: $CANONICAL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Update version.json & commit (버전 인수 지정 시) ──────────
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -n "$VERSION_ARG" ] && [ "$VERSION_ARG" != "$LATEST_TAG" ]; then
  # version.json 업데이트
  python3 -c "
import json
data = json.load(open('$VERSION_FILE'))
data['version'] = '$CANONICAL'
with open('$VERSION_FILE', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
"
  # README 버전 배지 업데이트
  PREV="${LATEST_TAG#v}"
  NEW="${CANONICAL#v}"
  PREV_ESC=$(echo "$PREV" | sed 's/\./\\./g')
  LTAG_ESC=$(echo "$LATEST_TAG" | sed 's/\./\\./g')
  for f in README.md README.en.md; do
    [ -f "$f" ] && sed -i \
      -e "s/# ai-coding-safety ${LTAG_ESC}/# ai-coding-safety ${CANONICAL}/g" \
      -e "s/Version-${PREV_ESC}-blueviolet/Version-${NEW}-blueviolet/g" \
      "$f"
  done

  # CHANGELOG prepend
  TODAY=$(date +%Y-%m-%d)
  PREV_TAG="$LATEST_TAG"
  if [ -n "$PREV_TAG" ]; then
    GIT_LOG=$(git log "${PREV_TAG}..HEAD" --oneline --no-merges 2>/dev/null || true)
  else
    GIT_LOG=$(git log --oneline --no-merges | head -20 || true)
  fi
  ENTRY="## $CANONICAL ($TODAY)\n"
  [ -n "$GIT_LOG" ] && ENTRY+="$(echo "$GIT_LOG" | sed 's/^[a-f0-9]* /- /')\n" || ENTRY+="- (변경 없음)\n"
  ENTRY+="\n---\n\n"
  if [ -f CHANGELOG.md ]; then
    (printf '%b' "$ENTRY"; cat CHANGELOG.md) > CHANGELOG.md.new
  else
    printf '%b' "$ENTRY" > CHANGELOG.md.new
  fi
  mv CHANGELOG.md.new CHANGELOG.md

  git add "$VERSION_FILE" CHANGELOG.md
  [ -f README.md ]    && git add README.md
  [ -f README.en.md ] && git add README.en.md
  git commit -m "chore: version $CANONICAL bump"
  git push origin "$(git rev-parse --abbrev-ref HEAD)"
  echo "✅ 버전 업데이트 완료: $CANONICAL"
  echo ""
fi

# ── Version consistency check ──────────────────────────────────
if [ -f ".githooks/pre-push" ]; then
  bash ".githooks/pre-push" || { echo "❌ 버전 검사 실패 — 중단합니다."; exit 1; }
fi

# ── Handle existing release ────────────────────────────────────
if gh release view "$CANONICAL" > /dev/null 2>&1; then
  if [ "$FORCE" != "true" ]; then
    echo "⚠️  $CANONICAL 릴리즈가 이미 존재합니다."
    if [ -t 0 ]; then
      read -p "   덮어쓰시겠습니까? (y/N): " -n 1 -r; echo ""
      [[ ! $REPLY =~ ^[Yy]$ ]] && echo "   취소합니다." && exit 0
    else
      echo "   비대화형 환경에서는 자동 취소합니다. -f 로 강제 가능."
      exit 0
    fi
  fi
  gh release delete "$CANONICAL" --yes
fi

# ── Release notes ──────────────────────────────────────────────
NOTES=""
CANONICAL_ESC=$(echo "$CANONICAL" | sed 's/\./\\./g')
if [ -f "CHANGELOG.md" ]; then
  NOTES=$(awk "/^## ${CANONICAL_ESC} /{found=1; next} found && /^## /{exit} found{print}" CHANGELOG.md)
fi
[ -z "$NOTES" ] && NOTES="Release $CANONICAL"

# ── Release title ──────────────────────────────────────────────
TITLE="$CANONICAL"
if [ -f "$VERSION_FILE" ]; then
  DESC=$(python3 -c "import json; print(json.load(open('$VERSION_FILE')).get('description',''))" 2>/dev/null)
  [ -n "$DESC" ] && TITLE="$CANONICAL - $DESC"
fi

# ── Create release ─────────────────────────────────────────────
echo "🚀 GitHub 릴리즈 생성 중..."
gh release create "$CANONICAL" --title "$TITLE" --notes "$NOTES"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 릴리즈 완료: $CANONICAL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
