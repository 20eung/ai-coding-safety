#!/bin/bash
# ai-coding-safety — Project Hook Installer
# Installs safety hooks for the current git project.
# Run once per project (from the project root).
#
# Usage: bash scripts/install-project.sh

set -e

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$REPO_ROOT" ]; then
  echo "❌ ERROR: git 저장소 루트를 찾을 수 없습니다."
  echo "   프로젝트 루트 디렉토리에서 실행하세요."
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

mkdir -p "$HOOKS_DIR"
mkdir -p "scripts"

# pre-commit
if [ -f "$HOOKS_DIR/pre-commit" ]; then
  echo "   ⏭️  pre-commit 이미 존재 — 건너뜁니다."
else
  echo "   📥 pre-commit 설치 중..."
  curl -fsSL "$REPO/project/pre-commit" -o "$HOOKS_DIR/pre-commit"
fi

# pre-push
if [ -f "$HOOKS_DIR/pre-push" ]; then
  echo "   ⏭️  pre-push 이미 존재 — 건너뜁니다."
else
  echo "   📥 pre-push 설치 중..."
  curl -fsSL "$REPO/project/pre-push" -o "$HOOKS_DIR/pre-push"
fi

# release.sh
if [ -f "scripts/release.sh" ]; then
  echo "   ⏭️  scripts/release.sh 이미 존재 — 건너뜁니다."
else
  echo "   📥 scripts/release.sh 설치 중..."
  curl -fsSL "$REPO/project/release.sh" -o "scripts/release.sh"
fi

chmod +x "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/pre-push" "scripts/release.sh"
git config core.hooksPath "$HOOKS_DIR"

echo ""
echo "✅ 프로젝트 훅 설치 완료"
echo ""
echo "   활성화된 훅:"
echo "   - pre-commit : 프로젝트 전용 보안 검사"
echo "   - pre-push   : 버전 일관성 검사 (커스터마이징 필요)"
echo ""
echo "   다음 단계:"
echo "   1. .githooks/pre-commit 에서 BLOCKED_FILES 설정"
echo "   2. .githooks/pre-push 에서 VERSION_FILE 및 검사 파일 설정"
echo "   3. bash .githooks/pre-commit && bash .githooks/pre-push  (동작 확인)"
echo ""
echo "   GitHub 릴리즈:"
echo "   - bash scripts/release.sh          # 자동 버전 감지"
echo "   - bash scripts/release.sh v1.2.3   # 버전 직접 지정"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
