#!/bin/bash
# Format Code Hook — PreToolUse (Edit|Write)
# Auto-formats code after edits to maintain style consistency

set -euo pipefail

# Read tool input to extract file path
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file"[^}]*' | sed 's/.*"file"[:"]*//;s/[",}].*//' || true)

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Determine formatter by extension
case "$FILE_PATH" in
  *.py)
    if command -v black >/dev/null 2>&1; then
      black -q "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  *.js|*.jsx|*.ts|*.tsx|*.json|*.md|*.yml|*.yaml)
    if command -v prettier >/dev/null 2>&1; then
      prettier --write "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  *.sh)
    if command -v shfmt >/dev/null 2>&1; then
      shfmt -w "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
esac

exit 0
