#!/bin/bash
# Format Code Hook — PreToolUse (Edit|Write)
# Auto-formats code after edits to maintain style consistency
# Receives: JSON on stdin describing the tool call

set -euo pipefail

# If stdin is empty, skip
if [ -t 0 ]; then
  exit 0
fi

INPUT=$(cat) || true
if [ -z "$INPUT" ]; then
  exit 0
fi

# Extract file path from JSON stdin using jq if available, fallback to grep
if command -v jq >/dev/null 2>&1; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.file // .file_path // empty' 2>/dev/null || true)
else
  FILE_PATH=$(echo "$INPUT" | grep -o '"file"[^,}]*' | head -1 | sed 's/.*"file"[[:space:]]*:[[:space:]]*"//;s/".*//' 2>/dev/null || true)
fi

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Determine formatter by extension
case "$FILE_PATH" in
  *.py)
    if command -v black >/dev/null 2>&1; then
      black -q "$FILE_PATH" 2>/dev/null || true
    fi
    if command -v ruff >/dev/null 2>&1; then
      ruff check --fix "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  *.js|*.jsx|*.ts|*.tsx|*.json|*.md|*.yml|*.yaml)
    if command -v prettier >/dev/null 2>&1; then
      prettier --write "$FILE_PATH" 2>/dev/null || true
    fi
    if command -v eslint >/dev/null 2>&1; then
      eslint --fix "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  *.sh)
    if command -v shfmt >/dev/null 2>&1; then
      shfmt -w "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
esac

exit 0
