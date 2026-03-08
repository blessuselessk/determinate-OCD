# thaw

> SemVer-aware upgrade tool for Nix flake inputs.

Source: `github:snowfallorg/thaw`

### Purpose

Upgrades Nix flake inputs using semantic versioning. Detects SemVer refs and applies compatible updates (minor+patch by default, major with `--major`). Supports GitHub, GitLab, Gitea, SourceHut.

### Syntax

```bash
# Upgrade all inputs (minor+patch)
thaw

# Upgrade specific inputs
thaw input1 input2

# Allow major version bumps
thaw --major

# Initialize inputs to latest versions
thaw --init

# Preview without applying
thaw --dry-run

# Options
thaw -f <dir>          # alternate flake directory
thaw -v / -vv / -vvv   # increase verbosity
```

### Installation

```bash
nix profile install github:snowfallorg/thaw
```

### Use Cases

- **Safe dependency updates**: respect SemVer constraints by default
- **Batch initialization**: set all inputs to current versions with `--init`
- **Controlled rollouts**: minor-only by default, opt-in to major bumps
