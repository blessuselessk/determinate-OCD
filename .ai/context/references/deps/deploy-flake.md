# deploy-flake

> Rust CLI for deploying NixOS flake configs to remote systems via SSH — builds on target, safe activation.

Source: `github:boinkor-net/deploy-flake`

### Purpose

Deploys NixOS system configurations from Nix flakes to remote hosts. Builds on the target system (no remote build server needed — works from macOS). Activates in stages: `nixos-rebuild test` first, then boot config only on success.

### Syntax

```bash
# Deploy to one or more hosts
nix run ./#deploy-flake -- host1 nixos://host2/webserver

# Arguments: simple hostnames or URIs with target config
#   hostname              → default NixOS config
#   nixos://host/config   → specific nixosConfiguration
```

### Key Features

- **Builds on target**: no cross-compilation or remote builders needed
- **Staged activation**: test before switching boot config
- **Pre-activation checks**: auto-detects preroll-safety scripts
- **Parallel deployment**: multiple hosts in one invocation
- **Background activation**: uses `systemd-run` so SSH disconnect won't interrupt

### Limitations

- No automatic rollback on failure (experimental)
- No pre-deploy safety checks (e.g., SSH lockout detection)
- No timeout mechanisms

### Use Cases

- **Cross-platform deploy**: push NixOS configs from macOS dev machines
- **Multi-host management**: parallel deployment to fleet
- **Safe upgrades**: test activation before committing to boot
