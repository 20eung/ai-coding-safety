#!/bin/bash
# ai-coding-safety — Project Hook Installer
# 현재 git 프로젝트에 안전 훅을 설치합니다.
# 프로젝트 루트에서 1회 실행하세요.
#
# Usage: bash scripts/install-project.sh

set -e

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$REPO_ROOT" ]; then
  echo "❌ git 저장소 루트를 찾을 수 없습니다. 프로젝트 루트에서 실행하세요."
  exit 1
fi

cd "$REPO_ROOT"

HOOKS_DIR=".githooks"
REPO="https://raw.githubusercontent.com/20eung/ai-coding-safety/main"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 프로젝트 Git 훅 설치 중..."
echo "   경로: $REPO_ROOT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

mkdir -p "$HOOKS_DIR" scripts

_install() {
  local SRC="$1" DST="$2"
  if [ -f "$DST" ]; then
    echo "   ⏭️  $DST — 이미 존재, 건너뜁니다."
  else
    echo "   📥 $DST 설치 중..."
    curl -fsSL "$REPO/$SRC" -o "$DST"
  fi
}

_install "project/pre-commit"  "$HOOKS_DIR/pre-commit"
_install "project/pre-push"    "$HOOKS_DIR/pre-push"
_install "project/release.sh"  "scripts/release.sh"

chmod +x "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/pre-push" "scripts/release.sh"
git config core.hooksPath "$HOOKS_DIR"

echo ""
echo "✅ 설치 완료"
echo ""
echo "   활성화된 훅:"
echo "   - pre-commit : 프로젝트 전용 보안 검사"
echo "   - pre-push   : 버전 일관성 검사"
echo ""
echo "   다음 단계:"
echo "   1. .githooks/pre-commit — BLOCKED_FILES 설정"
echo "   2. .githooks/pre-push   — VERSION_FILE 및 검사 파일 설정"
echo "   3. bash .githooks/pre-commit && bash .githooks/pre-push  (동작 확인)"
echo ""
echo "   GitHub 릴리즈:"
echo "   - bash scripts/release.sh          # 자동 버전 감지"
echo "   - bash scripts/release.sh v1.2.3   # 버전 직접 지정"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
