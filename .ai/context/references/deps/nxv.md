# nxv

> CLI that indexes nixpkgs git history to find any version of any Nix package instantly.

Source: `github:utensils/nxv`

### Purpose

Searches 8+ years of nixpkgs package history using Bloom filters and SQLite FTS5. Locates exact commits where a specific package version existed, so you can pin with `nix shell nixpkgs/<commit>#package`.

### Syntax

```bash
nxv search python          # find packages matching "python"
nxv search python 3.11     # filter by version
nxv info python             # package details
nxv history python          # version timeline
nxv update                  # download/update local index
nxv serve                   # run HTTP API server
```

### Key Features

- ~7MB binary, ~100MB compressed index
- Multiple interfaces: CLI, HTTP API, remote API
- NixOS module for systemd service with auto-updates
- Web UI at https://nxv.urandom.io

### Use Cases

- **Legacy version pinning**: find exact commits for old package versions
- **Package archaeology**: when was a package added/removed/updated
- **Reproducibility**: pin to a specific nixpkgs commit for a known version
