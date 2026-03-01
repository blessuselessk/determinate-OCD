______________________________________________________________________

## description: "CI pipeline — GitHub Actions workflow, checks, failure patterns, debugging"

# CI Operations Reference

Reference for the GitHub Actions CI pipeline. Load when debugging CI failures, adding new checks, or understanding what runs on push/PR.

## Pipeline Overview

```
push/PR to main
  → checkout
  → DeterminateSystems/nix-installer-action
  → DeterminateSystems/magic-nix-cache-action
  → nix flake check --print-build-logs
  → (build job — placeholder until hosts configured)
```

Source: `.github/workflows/ci.yml`

## Jobs

### `check` — Nix Flake Check

Runs on every push to `main` and every PR targeting `main`.

Steps:

1. `actions/checkout@v4`
1. `DeterminateSystems/nix-installer-action@main` — installs Determinate Nix
1. `DeterminateSystems/magic-nix-cache-action@main` — binary cache for CI
1. `nix flake check --print-build-logs` — runs all flake checks

### `build` — Build NixOS System

Depends on `check` passing. Currently a placeholder:

```yaml
run: echo "System build will be enabled once hosts are configured"
```

When hosts are ready, uncomment:

```yaml
run: nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel --print-build-logs
```

## Checks That Run

`nix flake check` executes all `checks.<system>.*` outputs. This project defines:

| Check | What it validates | Fix |
|-------|-------------------|-----|
| `context-compile` | All Typst templates render without errors | Fix the TOML source or template |
| `context-docs-fresh` | Installed files match built output (byte-for-byte diff) | `nix run .#write-context-docs` |
| `dep-refs-fresh` | Every dep in `manifest.toml` has a `.md` file | `nix run .#update-dep-refs` |
| `check-flake-file` | `flake.nix` matches what `write-flake` would generate | `nix run .#write-flake` |
| `treefmt` | All files pass nixfmt formatting | `nix fmt` |

## Determinate Systems Actions

| Action | Purpose |
|--------|---------|
| `nix-installer-action` | Installs Determinate Nix (not upstream Nix). Includes `determinate-nixd`, FlakeHub integration. |
| `magic-nix-cache-action` | Transparent binary cache backed by GitHub Actions cache. Speeds up builds by caching store paths. |

## Common Failure Patterns

### `context-docs-fresh` fails

**Cause**: TOML sources or templates changed but rendered outputs weren't regenerated.

```
ERROR: Generated context docs are stale: networking.md AGENTS.md
Run: nix run .#write-context-docs
```

**Fix**: `nix run .#write-context-docs` then commit the updated outputs.

### `dep-refs-fresh` fails

**Cause**: New dependency added to `manifest.toml` but reference `.md` not generated.

```
ERROR: Missing dep reference files: new-dep.md
Run: nix run .#update-dep-refs
```

**Fix**: `nix run .#update-dep-refs` then commit.

### `check-flake-file` fails

**Cause**: Module options changed flake inputs but `flake.nix` wasn't regenerated.

**Fix**: `nix build .#write-flake` then `cp result/bin/write-flake flake.nix` (macOS) or `nix run .#write-flake` (Linux).

### `treefmt` fails

**Cause**: Nix files don't pass `nixfmt`. Common issues: unused parameters, inline attrsets that should be expanded.

**Fix**: `nix fmt` to auto-format, then commit.

### `context-compile` fails

**Cause**: A TOML source has invalid schema or a Typst template has a rendering error.

**Fix**: Check the build log for the specific file and error. Common issues:

- Missing required `[aspect]` section in description TOML
- TOML syntax errors (e.g., `[[section.array]]` before scalar keys)
- Typst type mismatches from malformed input data

## Local Reproduction

```bash
# Run exactly what CI runs
nix flake check --print-build-logs

# Run a specific check
nix build .#checks.x86_64-linux.context-docs-fresh  # Linux
nix build .#checks.aarch64-darwin.context-docs-fresh # macOS

# Build what the build job would build (when enabled)
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

## Permissions

CI runs with `contents: read` only — it cannot push, create PRs, or modify the repository.
