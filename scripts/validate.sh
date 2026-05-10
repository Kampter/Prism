#!/bin/bash
# Prism Harness Validation Script
# Validates configuration files, agents, skills, hooks, and rules

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

# Validate .mcp.json
if [ -f .mcp.json ]; then
  if python3 -m json.tool .mcp.json >/dev/null 2>&1; then
    echo "  [PASS] .mcp.json"
  else
    echo "  [FAIL] .mcp.json — invalid JSON"
    ERRORS=$((ERRORS + 1))
  fi
else
  echo "  [FAIL] .mcp.json — missing"
  ERRORS=$((ERRORS + 1))
fi

# Validate agent definitions
if [ -d .claude/agents ] && [ "$(ls -A .claude/agents/*.md 2>/dev/null | wc -l)" -gt 0 ]; then
  for agent in .claude/agents/*.md; do
    if [ -f "$agent" ]; then
      if grep -q '^---$' "$agent" && grep -q 'name:' "$agent" && grep -q 'description:' "$agent"; then
        echo "  [PASS] Agent: $(basename "$agent")"
      else
        echo "  [FAIL] Agent: $(basename "$agent") — missing YAML frontmatter (---, name, description)"
        ERRORS=$((ERRORS + 1))
      fi
    fi
  done
else
  echo "  [WARN] No agents found in .claude/agents/"
fi

# Validate skill definitions
if [ -d .claude/skills ] && [ "$(ls -A .claude/skills/*.md 2>/dev/null | wc -l)" -gt 0 ]; then
  for skill in .claude/skills/*.md; do
    if [ -f "$skill" ]; then
      if grep -q '^# /' "$skill"; then
        echo "  [PASS] Skill: $(basename "$skill")"
      else
        echo "  [FAIL] Skill: $(basename "$skill") — missing command header (# /command)"
        ERRORS=$((ERRORS + 1))
      fi
    fi
  done
else
  echo "  [WARN] No skills found in .claude/skills/"
fi

# Validate hook scripts
if [ -d .claude/hooks ] && [ "$(ls -A .claude/hooks/*.sh 2>/dev/null | wc -l)" -gt 0 ]; then
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
else
  echo "  [WARN] No hooks found in .claude/hooks/"
fi

# Validate rules
if [ -d .claude/rules ] && [ "$(ls -A .claude/rules/*.md 2>/dev/null | wc -l)" -gt 0 ]; then
  for rule in .claude/rules/*.md; do
    if [ -f "$rule" ]; then
      if grep -q '^---$' "$rule" && grep -q 'pattern:' "$rule"; then
        echo "  [PASS] Rule: $(basename "$rule")"
      else
        echo "  [FAIL] Rule: $(basename "$rule") — missing frontmatter (---, pattern)"
        ERRORS=$((ERRORS + 1))
      fi
    fi
  done
else
  echo "  [WARN] No rules found in .claude/rules/"
fi

# Validate CLAUDE.md
if [ -f CLAUDE.md ]; then
  echo "  [PASS] CLAUDE.md"
else
  echo "  [FAIL] CLAUDE.md — missing"
  ERRORS=$((ERRORS + 1))
fi

# Validate README.md
if [ -f README.md ]; then
  echo "  [PASS] README.md"
else
  echo "  [WARN] README.md — missing (recommended for public repos)"
fi

# Validate .gitignore
if [ -f .gitignore ]; then
  if grep -q '\.env' .gitignore; then
    echo "  [PASS] .gitignore"
  else
    echo "  [WARN] .gitignore — does not block .env files"
  fi
else
  echo "  [FAIL] .gitignore — missing"
  ERRORS=$((ERRORS + 1))
fi

# Validate GitHub Actions
if [ -d .github/workflows ] && [ "$(ls -A .github/workflows/*.yml 2>/dev/null | wc -l)" -gt 0 ]; then
  for workflow in .github/workflows/*.yml; do
    if [ -f "$workflow" ]; then
      echo "  [PASS] Workflow: $(basename "$workflow")"
    fi
  done
else
  echo "  [WARN] No GitHub Actions workflows found"
fi

# Validate hook executability
for hook in .claude/hooks/*.sh; do
  if [ -f "$hook" ] && [ ! -x "$hook" ]; then
    echo "  [WARN] Hook $(basename "$hook") is not executable (chmod +x)"
  fi
done

echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo "All validations passed."
  exit 0
else
  echo "$ERRORS validation(s) failed."
  exit 1
fi
