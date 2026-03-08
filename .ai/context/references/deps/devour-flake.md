# devour-flake

> Build all flake outputs in a single evaluation pass instead of per-output.

Source: `github:srid/devour-flake`

### Purpose

Optimizes building multiple flake outputs. Instead of `nix build .#a .#b ... .#z` (N evaluations), devour-flake creates an intermediary consumer flake that depends on all outputs, triggering a single evaluation. Handles packages, apps, checks, devShells, NixOS/darwin/HM configs.

### Syntax

```bash
# Quick usage
nix build github:srid/devour-flake \
  -L --no-link --print-out-paths \
  --override-input flake github:target/flake
```

Output: JSON file with all flake outputs organized by system, ready for cache push.

### Integration

```nix
# As a non-flake input
inputs.devour-flake = {
  url = "github:srid/devour-flake";
  flake = false;
};
# Then overlay into pkgs and use pkgs.devour-flake in scripts
```

### Use Cases

- **CI/CD pipelines**: build all outputs efficiently in one pass
- **Cache population**: push entire flake closure to binary cache
- **IFD-heavy projects**: amortize expensive evaluation costs
