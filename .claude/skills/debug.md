# /debug

Investigate and fix a bug using systematic debugging.

## Usage

```
/debug [error-message|issue-id]
```

## Steps

1. Parse the error message or fetch issue details
2. Search logs, traces, and recent commits for clues
3. Spawn `debugger` subagent with context
4. Reproduce the issue locally
5. Identify root cause and minimal fix
6. Write regression test
7. Apply fix and verify

## Arguments

- `error-message`: The error text or exception traceback
- `issue-id`: Linear/GitHub issue number (fetches via API)

## Example

```
/debug "TypeError: Cannot read property 'id' of undefined"
/debug PROJ-123
```
