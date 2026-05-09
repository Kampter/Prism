# Prism — Claude Code Harness

## Project Overview

Prism is a production-ready development harness demonstrating how top AI labs structure Claude Code for team-scale development. This repository serves as both a reference implementation and a working template for organizations adopting AI-assisted software engineering.

## Architecture Principles

1. **Explicit over implicit**: Every automation is declared, versioned, and auditable
2. **Defense in depth**: Hooks validate before tools execute; subagents enforce least-privilege
3. **Composable workflows**: Skills, agents, and MCP servers combine to handle complex tasks
4. **Context discipline**: CLAUDE.md provides project memory; subagents isolate context windows

## Directory Structure

```
.claude/
  agents/          # Subagent definitions (YAML frontmatter)
  skills/          # Slash commands (SKILL.md format)
  hooks/           # Hook scripts (PreToolUse, PostToolUse, etc.)
  rules/           # Path-scoped rules (auto-loaded for file patterns)
  settings.json    # Project-level permissions, hooks, sandbox config
.github/
  workflows/       # CI/CD automation (Claude Code review, test)
docs/              # Architecture decisions, runbooks, onboarding
scripts/           # Automation helpers (setup, validation)
```

## Quick Start

1. Install dependencies: `./scripts/setup.sh`
2. Review permissions: `cat .claude/settings.json`
3. Run validation: `./scripts/validate.sh`
4. Start developing: `claude` (auto-loads CLAUDE.md)

## Conventions

- **Python**: Black formatter, 88 char line length, type hints required
- **JavaScript**: Prettier, 100 char line length, JSDoc for public APIs
- **Commits**: Conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`)
- **Branches**: `main` is protected; use `feature/`, `fix/`, `hotfix/` prefixes
- **Tests**: Every PR must include unit tests; integration tests for API changes

## Security

- `.env` files are protected by PreToolUse hook (blocks Write/Edit)
- `node_modules/` and `.git/` are read-only for all subagents
- MCP servers use managed policies; secrets in environment variables only
- All code changes require review subagent approval before merge

## Tooling

- **Formatter**: Auto-runs on PostToolUse (Edit|Write)
- **Linter**: Pre-commit via PreToolUse hook
- **Tests**: Auto-detect test files changed, run relevant suite
- **Security scan**: Block commits containing secrets or SQL injection patterns
