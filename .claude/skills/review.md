# /review

Run a comprehensive code review on the current branch or a specific PR.

## Usage

```
/review [pr-number|branch-name]
```

## Steps

1. Identify the target: current branch changes, or fetch PR diff
2. Run `git diff` to get the changeset
3. Spawn the `code-reviewer` subagent with the diff
4. Spawn the `security-auditor` subagent in parallel
5. Collect both reviews and synthesize findings
6. Output:
   - Executive summary (1 paragraph)
   - Critical issues (must fix before merge)
   - Warnings (should fix)
   - Positive findings
   - Action items with owner suggestions

## Arguments

- `pr-number`: GitHub PR number (fetches via gh CLI)
- `branch-name`: Compare against main (`git diff main...branch`)
- (none): Review current working tree changes

## Example

```
/review 42
/review feature/auth-refactor
/review
```
