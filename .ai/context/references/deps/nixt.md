# nixt

> Unit testing framework for the Nix language.

Source: `github:nix-community/nixt`

### Purpose

Discovers and runs unit tests for Nix code. Supports standalone and flake-based projects with hierarchical test organization.

### Syntax

```bash
# Run tests
nixt ./nix/

# Options
nixt -v ./nix/          # verbose (show passing tests + error details)
nixt -l ./nix/          # list tests without running
nixt -w ./nix/          # watch mode
nixt -p ./tests/        # specify test path
```

### Test Structure

```nix
# Tests use blocks → suites → cases hierarchy
{ describe, it, ... }:
[
  (describe "math" [
    (it "adds numbers" (1 + 1 == 2))
    (it "multiplies" (2 * 3 == 6))
  ])
]
```

### Key Functions

| Function | Purpose |
|----------|---------|
| `block` / `block'` | Create test blocks from paths and suites |
| `describe` / `describe'` | Group cases into named suites |
| `it` | Define individual test case (must eval to bool) |
| `grow` | Build registry for CLI consumption (flake-based) |
| `inject` | Provide arguments to test files |

### Use Cases

- **Aspect validation**: unit test aspect logic before deploying
- **Library testing**: validate Nix utility functions
- **CI integration**: automated test runs in flake checks
