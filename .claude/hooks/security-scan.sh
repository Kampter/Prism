#!/bin/bash
# Security Scan Hook — PreToolUse (Edit|Write)
# Blocks commits containing secrets, credentials, or dangerous patterns

set -euo pipefail

# Patterns that should NEVER be written
BLOCKED_PATTERNS=(
  # Secrets
  'api[_-]?key\s*[:=]\s*["\047][a-zA-Z0-9]{16,}["\047]'
  'password\s*[:=]\s*["\047][^"\047]+["\047]'
  'secret\s*[:=]\s*["\047][a-zA-Z0-9]{16,}["\047]'
  'token\s*[:=]\s*["\047][a-zA-Z0-9]{16,}["\047]'
  'private[_-]?key\s*[:=]'
  'AWS_ACCESS_KEY_ID\s*='
  'AWS_SECRET_ACCESS_KEY\s*='
  # Dangerous functions
  'eval\s*\('
  'exec\s*\('
  'os\.system\s*\('
  'subprocess\.call\s*\([^)]*shell\s*=\s*True'
  # SQL injection risks
  'execute\s*\(["\047].*%s'
  'query\s*\(["\047].*\+'
)

# Get the file being edited from stdin (Claude Code passes JSON)
# If stdin is empty, skip (hook called without context)
if [ -t 0 ]; then
  exit 0
fi

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file"[^}]*' | head -1 || true)

# If we can't determine file, allow but log
if [ -z "$FILE_PATH" ]; then
  echo "Warning: security scan could not determine target file"
  exit 0
fi

# Check for blocked patterns in the tool input
for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$INPUT" | grep -qiE "$pattern"; then
    echo "SECURITY BLOCK: Detected dangerous pattern matching '$pattern'"
    echo "This write has been blocked. Please use environment variables for secrets."
    exit 1
  fi
done

exit 0
