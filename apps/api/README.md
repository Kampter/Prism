# API Backend

FastAPI + LangGraph + Claude API

## Structure

| Directory | Purpose |
|-----------|---------|
| `agents/` | LangGraph agent definitions |
| `routes/` | FastAPI route handlers |
| `services/` | Business logic (GitHub fetch, RSS parse, RAG) |
| `models/` | Pydantic data models |
| `tools/` | Agent tools (search evidence, fetch GitHub, etc.) |
| `config/` | Configuration files |
| `tests/` | Test suite |
