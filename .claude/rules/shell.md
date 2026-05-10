---
pattern: "*.sh"
---

# Shell Script Conventions

- Always start with `#!/bin/bash`
- Always use `set -euo pipefail`
- Quote all variables: `"$var"` not `$var`
- Prefer `[[ ]]` over `[ ]` for conditionals
- Use `shellcheck` for static analysis
- Document exit codes
- `shfmt` for formatting
- Avoid backticks, use `$()` instead
