#!/bin/bash
# Prism Harness Setup Script
# Run once after cloning to install dependencies and verify configuration

set -euo pipefail

echo "=== Prism Claude Code Harness Setup ==="

# Check Claude Code is installed
if ! command -v claude >/dev/null 2>&1; then
  echo "Error: Claude Code CLI not found. Install from https://claude.ai/download"
  exit 1
fi

echo "Claude Code: $(claude --version)"

# Verify directory structure
for dir in .claude/agents .claude/skills .claude/hooks .claude/rules .github/workflows docs scripts; do
  if [ -d "$dir" ]; then
    echo "  [OK] $dir"
  else
    echo "  [CREATE] $dir"
    mkdir -p "$dir"
  fi
done

# Make hooks executable
chmod +x .claude/hooks/*.sh 2>/dev/null || true

# Verify settings.json syntax
if [ -f .claude/settings.json ]; then
  if python3 -m json.tool .claude/settings.json >/dev/null 2>&1; then
    echo "  [OK] .claude/settings.json"
  else
    echo "  [ERROR] .claude/settings.json is invalid JSON"
    exit 1
  fi
fi

# Check for required tools
for tool in git python3 uv node pnpm; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "  [OK] $tool"
  else
    echo "  [WARN] $tool not found (optional)"
  fi
done

echo ""
echo "Setup complete. Run 'claude' to start a session."
echo "Quick commands:"
echo "  /review     — Run code review"
echo "  /test       — Generate or run tests"
echo "  /debug      — Investigate bugs"
echo "  /commit     — Create conventional commit"
