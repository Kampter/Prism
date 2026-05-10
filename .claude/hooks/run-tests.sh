#!/bin/bash
# Run Tests Hook — PostToolUse (Edit|Write)
# Auto-runs relevant tests after code changes
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

# Extract file path from JSON stdin
if command -v jq >/dev/null 2>&1; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.file // .file_path // empty' 2>/dev/null || true)
else
  FILE_PATH=$(echo "$INPUT" | grep -o '"file"[^,}]*' | head -1 | sed 's/.*"file"[[:space:]]*:[[:space:]]*"//;s/".*//' 2>/dev/null || true)
fi

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")
DIRNAME=$(dirname "$FILE_PATH"
)

# Python
if [[ "$FILE_PATH" == *.py ]]; then
  # Try common test file naming conventions
  TEST_FILES=(
    "${DIRNAME}/test_${BASENAME}"
    "${DIRNAME}/tests/test_${BASENAME}"
    "tests/test_${BASENAME}"
    "tests/${DIRNAME}/test_${BASENAME}"
  )

  for TEST_FILE in "${TEST_FILES[@]}"; do
    if [ -f "$TEST_FILE" ] && command -v pytest >/dev/null 2>&1; then
      echo "[Prism] Running tests: $TEST_FILE" >&2
      pytest "$TEST_FILE" -q --tb=short 2>&1 || true
      break
    fi
  done
fi

# JavaScript/TypeScript
if [[ "$FILE_PATH" == *.js ]] || [[ "$FILE_PATH" == *.ts ]] || [[ "$FILE_PATH" == *.jsx ]] || [[ "$FILE_PATH" == *.tsx ]]; then
  EXT="${BASENAME##*.}"
  NAME="${BASENAME%.*}"
  TEST_FILES=(
    "${DIRNAME}/${NAME}.test.${EXT}"
    "${DIRNAME}/${NAME}.spec.${EXT}"
    "${DIRNAME}/__tests__/${NAME}.test.${EXT}"
  )

  for TEST_FILE in "${TEST_FILES[@]}"; do
    if [ -f "$TEST_FILE" ]; then
      if [ -f "package.json" ]; then
        if command -v npx >/dev/null 2>&1 && [ -f "node_modules/.bin/vitest" ]; then
          echo "[Prism] Running tests: $TEST_FILE" >&2
          npx vitest run "$TEST_FILE" --reporter=dot 2>&1 || true
        elif command -v npx >/dev/null 2>&1 && [ -f "node_modules/.bin/jest" ]; then
          echo "[Prism] Running tests: $TEST_FILE" >&2
          npx jest "$TEST_FILE" --silent 2>&1 || true
        fi
      fi
      break
    fi
  done
fi

exit 0
