# nvd

> Diff package versions across Nix store path closures.

Source: `sr.ht/~khumba/nvd`

### Purpose

Compares package versions between two Nix store paths, summarizing additions, removals, version bumps, and rebuilds. Highlights packages in your explicit `systemPackages`.

### Syntax

```bash
# Basic diff
nvd diff <path1> <path2>

# Typical workflow: build then diff before switching
nixos-rebuild build "$@" && nvd diff /run/current-system result
```

### Use Cases

- **Pre-switch review**: see what changes before committing to an update
- **Profile comparison**: diff any two system profiles or generations
- **Package tracking**: identify newly added or removed packages
