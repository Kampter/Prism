# Prism — Production Claude Code Harness

[![Claude Code](https://img.shields.io/badge/Claude%20Code-2.1+-blue)](https://claude.ai/code)
[![Validation](https://img.shields.io/badge/tests-13%2F13%20passing-green)]()

A production-ready development harness demonstrating how top AI labs structure Claude Code for team-scale software engineering. This repository is both a reference implementation and a working template.

## What is a Harness?

A Claude Code harness is the combination of configuration files, automation scripts, subagent definitions, and integration hooks that transform Claude from a conversational assistant into a structured, auditable, team-capable development partner.

## Quick Start

```bash
# Clone and enter the repo
cd Prism

# Run setup (checks tools, validates config)
./scripts/setup.sh

# Validate harness integrity
./scripts/validate.sh

# Start developing
claude
```

## Directory Structure

```
.claude/
  agents/          # Subagent definitions (YAML frontmatter)
  skills/          # Slash commands (SKILL.md format)
  hooks/           # Lifecycle automation scripts
  rules/           # Path-scoped conventions
  settings.json    # Project-level permissions & config
.github/
  workflows/       # CI/CD automation
docs/
  harness-guide.md # Full best practices guide
scripts/
  setup.sh         # Environment initialization
  validate.sh      # Config integrity checker
CLAUDE.md          # Project instructions (auto-loaded)
.mcp.json          # MCP server configuration
```

## Available Slash Commands

| Command | Description |
|---------|-------------|
| `/review [pr]` | Parallel code review + security audit |
| `/test [pattern]` | Generate or run tests |
| `/debug [error]` | Systematic bug investigation |
| `/commit [type]` | Create conventional commit |

## Subagents

| Agent | Role | Permissions |
|-------|------|-------------|
| `code-reviewer` | Read-only code analysis | Read, git diff, grep |
| `security-auditor` | Vulnerability scanning | Read-only (writes blocked) |
| `test-writer` | Test automation | Read, Edit, Write, test runners |
| `debugger` | Systematic debugging | Read, grep, logs |

## Security Layers

1. **Permission Layer** — `settings.json` deny rules block `.env`, lockfiles, `.git/`, `sudo`, `rm -rf`
2. **Hook Layer** — `PreToolUse` regex scans for secrets, eval(), SQL injection, path traversal
3. **Sandbox Layer** — OS-level isolation (Seatbelt/bubblewrap) with readonly paths
4. **Agent Isolation** — Read-only agents cannot modify code; security-auditor blocked from all writes

## CI/CD

GitHub Actions automatically runs on every PR:
- **Code Review** — Claude Code `/review` posts findings as PR comments
- **Security Audit** — Static analysis uploaded as artifact

Configure `ANTHROPIC_API_KEY` in GitHub repository secrets.

## Environment Variables

Required for MCP server integration (set in your shell, never commit):

| Variable | Used By |
|----------|---------|
| `GITHUB_TOKEN` | GitHub MCP, CI workflows |
| `DATABASE_URL` | PostgreSQL MCP |
| `SENTRY_AUTH_TOKEN` | Sentry MCP |
| `LINEAR_API_KEY` | Linear MCP |
| `ANTHROPIC_API_KEY` | CI/CD workflows |

## License

MIT — see [LICENSE](LICENSE)
