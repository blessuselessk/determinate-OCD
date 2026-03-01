---
description: "Build and deploy a NixOS configuration to a target host"
mode: agent
agent: denizen
---

## Phase 1: Pre-flight
1. Confirm target host exists in `den.hosts` (`nix eval .#nixosConfigurations --apply builtins.attrNames`)
2. Run `nix flake check` — all checks must pass before deploying
3. Verify all secrets are wired and encrypted files are tracked

**CHECKPOINT**: Confirm target host, all checks pass, and secrets are ready before building.

## Phase 2: Build
1. Build the system closure: `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel`
2. For ISO: `nix build .#nixosConfigurations.<hostname>.config.system.build.isoImage`
3. Verify the build completes without errors

## Phase 3: Deploy
1. Remote deploy via FlakeHub: `fh apply nixos "org/flake/*#nixosConfigurations.<hostname>"`
2. For ISO: write to USB or use in VM — manual install process
3. For local: `sudo nixos-rebuild switch --flake .#<hostname>`

## Phase 4: Validate
1. Verify the target host is reachable (SSH or console)
2. Check that services are running: `systemctl --failed`
3. Review activation log for errors: `journalctl -b -p err`
