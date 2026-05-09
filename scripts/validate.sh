#!/bin/bash
# Prism Harness Validation Script
# Validates configuration files, agents, skills, and hooks

set -euo pipefail

echo "=== Prism Harness Validation ==="
ERRORS=0

# Validate settings.json
if [ -f .claude/settings.json ]; then
  if python3 -m json.tool .claude/settings.json >/dev/null 2>&1; then
    echo "  [PASS] settings.json"
  else
    echo "  [FAIL] settings.json — invalid JSON"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "  [FAIL] settings.json — missing"
  ERRORS=$((ERRORS + 1))
fi

# Validate agent definitions
for agent in .claude/agents/*.md; do
  if [ -f "$agent" ]; then
    if grep -q '^---$' "$agent" && grep -q 'name:' "$agent"; then
      echo "  [PASS] Agent: $(basename "$agent")"
    else
      echo "  [FAIL] Agent: $(basename "$agent") — missing YAML frontmatter"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done

# Validate skill definitions
for skill in .claude/skills/*.md; do
  if [ -f "$skill" ]; then
    if grep -q '^# /' "$skill"; then
      echo "  [PASS] Skill: $(basename "$skill")"
    else
      echo "  [FAIL] Skill: $(basename "$skill") — missing command header"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done

# Validate hook scripts
for hook in .claude/hooks/*.sh; do
  if [ -f "$hook" ]; then
    if bash -n "$hook" 2>/dev/null; then
      echo "  [PASS] Hook: $(basename "$hook")"
    else
      echo "  [FAIL] Hook: $(basename "$hook") — syntax error"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done

# Validate CLAUDE.md
if [ -f CLAUDE.md ]; then
  echo "  [PASS] CLAUDE.md"
else
  echo "  [FAIL] CLAUDE.md — missing"
  ERRORS=$((ERRORS + 1))
fi

echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo "All validations passed."
  exit 0
else
  echo "$ERRORS validation(s) failed."
  exit 1
fi
