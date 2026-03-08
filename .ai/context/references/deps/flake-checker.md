# flake-checker

> Health inspection tool for flake.lock files — validates freshness, ownership, and branch support.

Source: `github:DeterminateSystems/flake-checker`

### Purpose

Validates that flake.lock dependencies use recent, supported versions of Nixpkgs. Checks branch verification, freshness (< 30 days), and origin validation (NixOS org).

### Syntax

```bash
# Basic check
nix run github:DeterminateSystems/flake-checker

# With explicit path
nix run github:DeterminateSystems/flake-checker /path/to/flake.lock
```

### Configuration Flags

| Flag | Env Var | Purpose |
|------|---------|---------|
| `--check-outdated` | `NIX_FLAKE_CHECKER_CHECK_OUTDATED` | Age validation |
| `--check-owner` | `NIX_FLAKE_CHECKER_CHECK_OWNER` | Ownership verification |
| `--check-supported` | `NIX_FLAKE_CHECKER_CHECK_SUPPORTED` | Branch status validation |
| `--condition` | — | Custom CEL-based policy rules |
| `--no-telemetry` | `FLAKE_CHECKER_NO_TELEMETRY` | Disable diagnostics reporting |

### Use Cases

- **CI/CD gating**: automated flake health checks before merge
- **Policy enforcement**: custom CEL conditions for org standards
- **Dependency auditing**: identify stale or unauthorized package sources
