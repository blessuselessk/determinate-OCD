# dix

> Blazingly fast Nix closure diff tool with JSON output support.

Source: `github:faukah/dix`

### Purpose

High-performance tool to compare Nix closures (derivation graphs). Shows package additions, removals, and version changes between system configurations.

### Syntax

```bash
# Compare two paths
dix <OLD_PATH> <NEW_PATH>

# Compare system generations
dix /nix/var/profiles/system-69-link /run/current-system

# Options
dix --output json <old> <new>       # JSON output for scripting
dix --force-correctness <old> <new> # accuracy over speed (for CI)
dix --color never <old> <new>       # disable color
```

### Use Cases

- **CI/CD validation**: compare system generations before deployment
- **System auditing**: review package changes between builds
- **Scripting**: JSON output for automated analysis
