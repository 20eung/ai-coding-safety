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

# ── Version source of truth ───────────────────────────────────
VERSION_FILE="version.json"

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

# ── Check latest release and handle conflicts ────────────────
LATEST_RELEASE=$(gh release list --limit 1 --json tagName --jq '.[0].tagName' 2>/dev/null || echo "")

if [ "$CANONICAL" = "$LATEST_RELEASE" ]; then
  # ── Prepare version bump previews ───────────────────────────
  P_PATCH=$(python3 -c "import sys; v=sys.argv[1].lstrip('v'); p=list(map(int,v.split('.'))); p[2]+=1; print('v'+'.'.join(map(str,p)))" "$CANONICAL")
  P_MINOR=$(python3 -c "import sys; v=sys.argv[1].lstrip('v'); p=list(map(int,v.split('.'))); p[1]+=1; p[2]=0; print('v'+'.'.join(map(str,p)))" "$CANONICAL")
  P_MAJOR=$(python3 -c "import sys; v=sys.argv[1].lstrip('v'); p=list(map(int,v.split('.'))); p[0]+=1; p[1]=0; p[2]=0; print('v'+'.'.join(map(str,p)))" "$CANONICAL")

  echo "⚠️  현재 버전 ($CANONICAL) 이 이미 GitHub 릴리즈에 존재합니다."
  echo "    원하시는 작업을 선택하세요:"
  echo "    1) Patch ($CANONICAL -> $P_PATCH)"
  echo "    2) Minor ($CANONICAL -> $P_MINOR)"
  echo "    3) Major ($CANONICAL -> $P_MAJOR)"
  echo "    4) Overwrite (기존 릴리즈 덮어쓰기)"
  echo "    5) Cancel (중단)"
  read -p "    선택 (1-5): " -n 1 -r
  echo ""

  case $REPLY in
    1) BUMP="patch" ;;
    2) BUMP="minor" ;;
    3) BUMP="major" ;;
    4) BUMP="overwrite" ;;
    *) echo "   릴리즈를 취소합니다."; exit 0 ;;
  esac

  if [ "$BUMP" != "overwrite" ]; then
    NEW_VERSION=$(python3 -c "
import sys
v = sys.argv[1].lstrip('v')
parts = list(map(int, v.split('.')))
bump = sys.argv[2]
if bump == 'major': parts[0] += 1; parts[1] = 0; parts[2] = 0
elif bump == 'minor': parts[1] += 1; parts[2] = 0
elif bump == 'patch': parts[2] += 1
print('v' + '.'.join(map(str, parts)))
" "$CANONICAL" "$BUMP")

    echo "🚀 버전을 $CANONICAL 에서 $NEW_VERSION 으로 올립니다..."
    
    # Update version.json
    python3 -c "
import json, sys
data = json.load(open('$VERSION_FILE'))
data['version'] = '$NEW_VERSION'
with open('$VERSION_FILE', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
"
    
    # Update README files
    CANONICAL_PLAIN="${CANONICAL#v}"
    NEW_VERSION_PLAIN="${NEW_VERSION#v}"
    sed -i "s/# ai-coding-safety $CANONICAL/# ai-coding-safety $NEW_VERSION/g" README.md README.en.md
    sed -i "s/Version-$CANONICAL_PLAIN-blueviolet/Version-$NEW_VERSION_PLAIN-blueviolet/g" README.md README.en.md
    
    # Update CHANGELOG.md (Prepend new section)
    DATE=$(date +%Y-%m-%d)
    NEW_HEADER="## $NEW_VERSION ($DATE)\n\n- \n\n---\n"
    (echo -e "$NEW_HEADER"; cat CHANGELOG.md) > CHANGELOG.md.new
    mv CHANGELOG.md.new CHANGELOG.md

    # Commit changes
    git add "$VERSION_FILE" README.md README.en.md CHANGELOG.md
    git commit -m "chore: version $NEW_VERSION bump"
    git push origin main
    
    CANONICAL="$NEW_VERSION"
    echo "✅ 버전 업데이트 및 푸시 완료: $CANONICAL"
    echo ""
  fi
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

# ── Check if release already exists (for overwrite case) ────────
if gh release view "$CANONICAL" > /dev/null 2>&1; then
  if [ "$BUMP" != "overwrite" ]; then
    echo "⚠️  $CANONICAL 릴리즈가 이미 대기 중입니다."
    read -p "   덮어쓰시겠습니까? (y/N): " -n 1 -r
    echo ""
    [[ ! $REPLY =~ ^[Yy]$ ]] && echo "   릴리즈를 취소합니다." && exit 0
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
