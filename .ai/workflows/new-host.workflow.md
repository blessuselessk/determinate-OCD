---
description: "Declare a new NixOS host with user bindings and host-specific aspects"
mode: agent
agent: nix-aspect-author
---

## Phase 1: Scope
1. Choose a hostname and system architecture (`x86_64-linux`, `aarch64-linux`, `aarch64-darwin`)
2. Identify user(s) to bind to the host
3. Decide which default includes apply (networking, boot, shell)

**CHECKPOINT**: Confirm hostname, architecture, and user(s) before proceeding.

## Phase 2: Declare
1. Add `den.hosts.<system>.<hostname>.users.<user> = { }` to `modules/hosts.nix`
2. Create a host aspect in `modules/` with boot, filesystem, and hardware config
3. Create or verify user aspect with `den.provides.primary-user` binding

## Phase 3: Wire
1. Add the host aspect to `den.default.includes` if it should apply to all hosts
2. Configure host-specific overrides in the host aspect (networking, services)
3. Wire any secrets the host needs via `includes` dependency on secrets aspect

## Phase 4: Verify
1. `jj file track` all new files
2. Run `nix flake check` — confirm `nixosConfigurations.<hostname>` appears in outputs
3. Review the host declaration: `nix eval .#nixosConfigurations --apply builtins.attrNames`
