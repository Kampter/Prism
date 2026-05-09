# /commit

Stage changes and create a conventional commit.

## Usage

```
/commit [type] [message]
```

## Steps

1. Run `git status` to see changed files
2. Run `git diff --stat` for summary
3. Auto-stage all modified files (`git add -A`)
4. Determine commit type from changes:
   - `feat`: New functionality
   - `fix`: Bug fix
   - `docs`: Documentation only
   - `style`: Formatting, no logic change
   - `refactor`: Code restructuring
   - `test`: Adding or updating tests
   - `chore`: Build, deps, tooling
5. Write descriptive message (imperative mood, under 72 chars)
6. Execute commit
7. Optionally push if tracking branch exists

## Arguments

- `type`: Commit type (feat, fix, docs, style, refactor, test, chore)
- `message`: Commit message subject

## Example

```
/commit feat "add OAuth2 login flow"
/commit fix "resolve race condition in cache invalidation"
/commit
```
