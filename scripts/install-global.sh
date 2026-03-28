#!/bin/bash
# ai-coding-safety — Global Hook Installer
# Installs security hooks that apply to ALL git repositories on this machine.
# Run once per machine.
#
# Usage: bash install-global.sh

set -e

HOOKS_DIR="$HOME/.githooks"
REPO="https://raw.githubusercontent.com/20eung/ai-coding-safety/main"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 글로벌 Git 훅 설치 중..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

mkdir -p "$HOOKS_DIR"

echo "📥 훅 다운로드 중..."

curl -fsSL "$REPO/global/pre-commit" -o "$HOOKS_DIR/pre-commit"
curl -fsSL "$REPO/global/pre-push"   -o "$HOOKS_DIR/pre-push"

chmod +x "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-push"

git config --global core.hooksPath "$HOOKS_DIR"

echo ""
echo "✅ 글로벌 훅 설치 완료"
echo ""
echo "   설치 경로: $HOOKS_DIR"
echo "   적용 범위: 이 머신의 모든 git 저장소"
echo ""
echo "   활성화된 훅:"
echo "   - pre-commit : 보안 검사 (API 키 / 민감 정보 커밋 방지)"
echo "   - pre-push   : 프로젝트 훅 체이닝"
echo ""
echo "   프로젝트별 훅 설치:"
echo "   bash install-project.sh  (프로젝트 루트에서 실행)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
