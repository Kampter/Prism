#!/bin/bash
# Security Scan Hook — PreToolUse (Edit|Write)
# Blocks commits containing secrets, credentials, or dangerous patterns
# Receives: JSON on stdin describing the tool call
# Exits 0 = allow, non-zero = block

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
  'ghp_[a-zA-Z0-9]{36}'
  'sk-[a-zA-Z0-9]{48}'
  # Dangerous functions
  '\beval\s*\('
  '\bexec\s*\('
  'os\.system\s*\('
  'subprocess\.call\s*\([^)]*shell\s*=\s*True'
  # SQL injection risks
  '\.execute\s*\(["\047].*%s'
  '\.query\s*\(["\047].*\+'
  'f["\047].*\{.*\}.*["\047]\s*\.format'
  # Path traversal
  '\.\.(/|\\\\)'
)

# If stdin is empty or terminal, skip scan (no file context available)
if [ -t 0 ]; then
  exit 0
fi

# Read stdin safely
INPUT=$(cat) || true
if [ -z "$INPUT" ]; then
  exit 0
fi

# Check for blocked patterns in the tool input
for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$INPUT" | grep -qiE "$pattern" 2>/dev/null; then
    echo "SECURITY BLOCK: Detected dangerous pattern matching '$pattern'" >&2
    echo "This write has been blocked. Secrets must use environment variables." >&2
    exit 1
  fi
done

exit 0
