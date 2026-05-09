# /test

Generate or run tests for the current changes.

## Usage

```
/test [file-pattern] [--run]
```

## Steps

1. Identify changed files (staged + unstaged)
2. Map source files to their test files
3. Spawn `test-writer` subagent for any new untested code
4. Run the test suite (auto-detect framework)
5. Report coverage and failures

## Arguments

- `file-pattern`: Only consider files matching pattern (e.g., `src/auth*`)
- `--run`: Only run existing tests, do not generate new ones

## Auto-detection

- `pytest` if `pytest.ini` or `conftest.py` exists
- `jest` if `jest.config.*` exists
- `vitest` if `vitest.config.*` exists
- `npm test` if `package.json` has test script

## Example

```
/test
/test src/auth/*
/test --run
```
