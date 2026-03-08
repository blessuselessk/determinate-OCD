# nix-melt

> Terminal UI for exploring flake.lock files in a ranger-like interface.

Source: `github:nix-community/nix-melt`

### Purpose

Displays the contents of `flake.lock` files interactively, making it easy to navigate complex dependency trees visually.

### Syntax

```bash
# Run directly
nix run github:nix-community/nix-melt

# With options
nix-melt [PATH]                    # path to flake.lock or its directory
nix-melt -t <TIME_FORMAT>         # customize timestamp display
```

### Use Cases

- **Dependency inspection**: browse locked input versions interactively
- **Debugging flakes**: understand which inputs are pinned and their structure
- **Audit workflows**: quickly survey the full dependency tree
