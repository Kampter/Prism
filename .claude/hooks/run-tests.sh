#!/bin/bash
# Run Tests Hook — PostToolUse (Edit|Write)
# Auto-runs relevant tests after code changes

set -euo pipefail

# Read tool input to extract file path
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file"[^}]*' | sed 's/.*"file"[:"]*//;s/[",}].*//' || true)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Map source file to test file and run
BASENAME=$(basename "$FILE_PATH")
DIRNAME=$(dirname "$FILE_PATH")

# Python
if [[ "$FILE_PATH" == *.py ]]; then
  TEST_FILE="${DIRNAME}/test_${BASENAME}"
  if [ -f "$TEST_FILE" ] && command -v pytest >/dev/null 2>&1; then
    echo "Running tests for $BASENAME..."
    pytest "$TEST_FILE" -q 2>&1 || true
  fi
fi

# JavaScript/TypeScript
if [[ "$FILE_PATH" == *.js ]] || [[ "$FILE_PATH" == *.ts ]]; then
  TEST_FILE="${DIRNAME}/${BASENAME%.js}.test.js"
  TEST_FILE="${TEST_FILE%.ts}.test.ts"
  if [ -f "$TEST_FILE" ] && [ -f "package.json" ]; then
    echo "Running tests for $BASENAME..."
    npm test -- "$TEST_FILE" 2>&1 || true
  fi
fi

exit 0
