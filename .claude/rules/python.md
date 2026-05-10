---
pattern: "*.py"
---

# Python Conventions

- Use type hints on all function signatures
- Prefer `pathlib.Path` over `os.path`
- Use `dataclasses` or `pydantic.BaseModel` for structured data
- Docstrings: Google style, one-line for simple functions
- F-strings over `.format()` or `%` formatting
- `black` formatter, 88 char line length
- `ruff` for linting (E, F, I rules)
- `mypy --strict` for type checking
- Tests: `pytest` with `pytest-cov` for coverage
- Target 80%+ line coverage
