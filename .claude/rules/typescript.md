---
pattern: "*.{ts,tsx}"
---

# TypeScript / React Conventions

- Strict TypeScript: `strict: true` in tsconfig
- Prefer `const` and `let` (no `var`)
- Use arrow functions for callbacks
- Component props: explicit interface, not `any`
- Error handling: never swallow errors silently
- `prettier` formatter, 100 char line length
- `eslint` with `@typescript-eslint` plugin
- Tests: `vitest` + `@testing-library/react`
- Prefer async/await over raw promises
- Use `fetch` or `ky` for HTTP, not `axios` unless needed
