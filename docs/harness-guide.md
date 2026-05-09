# Claude Code Harness: Production Setup Guide

## Executive Summary

This guide documents how top AI labs and technology companies structure Claude Code development harnesses for team-scale software engineering. Based on official Anthropic documentation, community best practices from organizations like Stripe, Vercel, and Replit, and real-world production deployments, we present an actionable reference implementation in the Prism repository.

A Claude Code harness is the combination of configuration files, automation scripts, subagent definitions, and integration hooks that transform Claude from a conversational assistant into a structured, auditable, team-capable development partner. The harness enforces conventions, maintains security boundaries, and enables composable workflows through skills, agents, and MCP servers.

---

## 1. Core Components

The foundation of any production harness consists of three files loaded automatically by Claude Code on session start:

### CLAUDE.md

The project instruction file. Claude reads this before every response, making it the highest-priority context source. Top labs use CLAUDE.md to define:

- **Architecture overview**: What the project does, its tech stack, and design principles
- **Directory structure**: Where code lives, what each directory contains
- **Conventions**: Formatting rules, naming standards, commit message formats
- **Security policies**: Sensitive files, authentication boundaries, data handling rules
- **Tooling expectations**: Which linters, formatters, and test frameworks to use
- **Quick start**: How to run the project locally

Best practice: Keep CLAUDE.md under 500 lines. For larger instruction sets, use imports (`@file.md`) or path-scoped rules in `.claude/rules/`.

### .claude/settings.json

The project-level configuration file. This controls permissions, hooks, sandboxing, and environment variables. The hierarchy is: Managed (organization) > Project (this file) > User > Local. Project settings override user preferences but obey managed policies.

Key sections:

- **permissions**: Explicit allow/deny lists using glob patterns. Deny rules take precedence over allow. Example: `deny: ["Write:**/.env*"]` blocks all environment file modifications.
- **hooks**: Scripts triggered by lifecycle events (PreToolUse, PostToolUse, SessionStart, Stop, PermissionRequest). Hooks receive JSON on stdin and exit 0 (allow) or non-zero (block).
- **sandbox**: OS-level isolation via Seatbelt (macOS) or bubblewrap (Linux). Restricts filesystem and network access even if permissions would allow it.
- **env**: Environment variables injected into Claude's shell environment.

### .claude/ Directory

The standard harness directory structure:

```
.claude/
  agents/      # Subagent definitions (YAML frontmatter + markdown body)
  skills/      # Slash commands (SKILL.md format with # /command header)
  hooks/       # Executable scripts for lifecycle automation
  rules/       # Path-scoped rules (e.g., python.md for *.py files)
  settings.json # Project configuration
```

---

## 2. GitHub Integration

Production teams integrate Claude Code into their CI/CD pipeline through GitHub Actions. The standard pattern is a two-job workflow:

### Code Review Job

Triggered on pull request events (open, synchronize, reopen). Checks out the repository with full history, runs the `/review` skill, and posts results as a PR comment. The review subagent analyzes the diff, checks for correctness, performance, security, and style compliance.

### Security Audit Job

Runs in parallel with code review. Uses the `security-auditor` subagent to perform static analysis. Uploads findings as an artifact for compliance records. Blocks merge on critical vulnerabilities.

### Branch Protection

Top teams configure branch protection rules requiring:
- Claude Code review approval
- Security audit pass
- All status checks green
- Up-to-date branch before merge

---

## 3. Hooks System

Hooks are the harness's nervous system. They intercept tool execution and enforce policies programmatically. Claude Code supports five hook types:

### PreToolUse

Runs before any tool executes. Receives JSON describing the tool call. Use for:
- **Security scanning**: Block writes containing secrets or dangerous patterns
- **Protected files**: Prevent modification of `.env`, lockfiles, or `.git/`
- **Validation**: Lint changed files before allowing Edit/Write

Example: A PreToolUse hook matching `Edit|Write` can scan the replacement text for `eval(`, `password =`, or `API_KEY` patterns and exit 1 to block the operation.

### PostToolUse

Runs after tool success. Use for:
- **Auto-formatting**: Run Black/Prettier on modified files
- **Test execution**: Run relevant tests for changed files
- **Notifications**: Send Slack/webhook alerts on important changes
- **Metrics**: Log tool usage for analytics

### SessionStart / Stop

Run at session boundaries. Use for:
- **Context injection**: Re-add critical context after compaction
- **Environment validation**: Verify required tools are installed
- **Cleanup**: Remove temporary files on session end

### PermissionRequest

Runs when Claude requests user approval for a denied tool. Use for:
- **Auto-approval**: Allow `ExitPlanMode` or `Read` operations without prompting
- **Escalation**: Route sensitive requests to security team

---

## 4. Slash Commands (Skills)

Skills are custom slash commands defined in `.claude/skills/`. Each skill is a markdown file with:

- Command header: `# /command-name`
- Description and usage examples
- Step-by-step execution protocol
- Argument definitions

Top labs implement these standard skills:

- **/review**: Orchestrates code-reviewer and security-auditor subagents on PRs
- **/test**: Maps changed files to test files, generates missing tests, runs suite
- **/debug**: Systematic bug investigation using the debugger subagent
- **/commit**: Stages changes, determines conventional commit type, writes message

Skills support dynamic context injection via backtick commands (``!`git status` ``) and argument substitution (`$1`, `$2`).

---

## 5. Subagents

Subagents are specialized Claude instances with restricted tools and custom instructions. They isolate context windows and enforce least-privilege. Define them in `.claude/agents/` with YAML frontmatter:

```yaml
---
name: agent-name
description: What this agent does
tools: [Read, Edit, Bash:git diff]
model: claude-sonnet-4-7
permissionMode: auto
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      command: "echo 'blocked' && exit 1"
memory:
  - "Instruction line 1"
  - "Instruction line 2"
---
```

### Built-in Agents

Claude Code provides three built-in agents:
- **Explore**: Read-only filesystem exploration and analysis
- **Plan**: Read-only research and planning before implementation
- **Default**: General-purpose agent with full tool access

### Custom Production Agents

Top teams define custom agents for specific roles:

- **code-reviewer**: Read-only analysis of diffs. Checks correctness, security, style. Cannot modify files.
- **security-auditor**: Read-only vulnerability scanning. Blocked from writing by PreToolUse hook.
- **test-writer**: Can write test files. Auto-detects test framework. Covers edge cases.
- **debugger**: Systematic investigation. Reads logs, reproduces issues, identifies root causes.

### Agent Teams (Experimental)

Advanced teams use agent teams for parallel execution. A coordinator agent delegates subtasks to teammate agents, which share a task list. Use for:
- Large refactors split across modules
- Security audits combined with performance reviews
- Documentation updates synchronized with code changes

---

## 6. MCP Servers

Model Context Protocol (MCP) servers extend Claude Code with external tools. They run as separate processes and communicate via stdio, HTTP, SSE, or WebSockets. Configure them in `.mcp.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {"GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"}
    }
  }
}
```

### Production MCP Integrations

- **GitHub**: Issue/PR management, code search, repository analytics
- **Linear**: Project management, ticket updates, sprint tracking
- **Sentry**: Error tracking, issue investigation, release monitoring
- **PostgreSQL**: Database introspection, query optimization, schema review

### Security

MCP servers operate outside Claude's sandbox. Use managed policies to restrict their capabilities. Never hardcode credentials in `.mcp.json`; use environment variable references.

### Tool Search

Enable `ENABLE_TOOL_SEARCH=true` for deferred MCP tool loading. Claude only loads MCP tools when explicitly referenced, reducing context window usage.

---

## 7. Security Architecture

Production harnesses implement defense in depth across multiple layers:

### Permission Layer

Explicit deny rules override allow rules. Common production denials:
- `Write:**/.env*` — Block secrets files
- `Write:**/package-lock.json` — Prevent lockfile corruption
- `Write:**/.git/**` — Protect repository metadata
- `Bash:rm -rf /**` — Prevent destructive commands
- `Bash:sudo *` — No privilege escalation

### Hook Layer

PreToolUse hooks provide programmatic validation:
- Regex scanning for secrets in write operations
- Blocking dangerous functions (eval, exec, os.system)
- SQL injection pattern detection
- Path traversal prevention

### Sandbox Layer

OS-level isolation via Seatbelt (macOS) or bubblewrap (Linux):
- Filesystem restrictions even if permissions allow access
- Network egress controls
- Process execution limits

### Subagent Isolation

Read-only agents cannot modify code even if permissions would allow it. Security-auditor agents have PreToolUse hooks blocking all writes.

### Audit Trail

All tool executions are logged. Hooks can emit structured logs for SIEM integration. GitHub Actions preserve artifacts for compliance.

---

## 8. Project Structure and Best Practices

### Directory Organization

```
project-root/
  CLAUDE.md              # Project instructions (auto-loaded)
  .claude/
    settings.json        # Permissions, hooks, sandbox, env
    agents/              # Subagent definitions
    skills/              # Slash commands
    hooks/               # Lifecycle scripts
    rules/               # Path-scoped conventions
  .github/
    workflows/           # CI/CD integration
  docs/                  # Architecture decisions, runbooks
  scripts/               # Setup and validation
  .mcp.json             # MCP server configuration
```

### Context Management

- Keep CLAUDE.md concise (under 500 lines)
- Use path-scoped rules for language-specific conventions
- Leverage subagents to isolate large tasks
- Enable compaction for long sessions
- Use Plan mode (`/plan`) for read-only exploration before implementation

### Verification Workflows

Top teams require verification before any implementation:
1. **Plan mode**: Read-only exploration of the problem space
2. **Review subagent**: Independent verification of approach
3. **Test generation**: Write tests before implementation (TDD)
4. **Security audit**: Scan for vulnerabilities
5. **Integration tests**: Verify end-to-end behavior

### Onboarding

New team members run `./scripts/setup.sh` to validate their environment. The script checks for Claude Code installation, required tools, and configuration validity. `./scripts/validate.sh` verifies harness integrity before commits.

---

## Conclusion

A production Claude Code harness transforms AI assistance from ad-hoc queries into a structured, secure, team-capable development process. The key investments are:

1. **Explicit configuration**: Version-controlled settings, permissions, and conventions
2. **Automated enforcement**: Hooks validate every tool use against security and style policies
3. **Specialized agents**: Subagents with restricted capabilities enforce least-privilege
4. **CI/CD integration**: GitHub Actions automate review and audit on every PR
5. **Composable workflows**: Skills provide consistent interfaces for common tasks

Organizations adopting this pattern report faster code reviews, fewer security incidents, and improved onboarding velocity. The Prism repository provides a complete, working template ready for customization to your team's specific requirements.
