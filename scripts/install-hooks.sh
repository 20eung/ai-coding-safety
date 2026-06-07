#!/bin/bash
# ai-coding-safety — Project Hook Installer (alias)
# This script is an alias for scripts/install-project.sh.
# Use either name — they do the same thing.
#
# Usage: bash scripts/install-hooks.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$SCRIPT_DIR/install-project.sh" "$@"
