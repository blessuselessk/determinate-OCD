---
name: host-declarations
description: |
  Den host declaration patterns and host-specific aspect wiring.
  Use when creating or modifying host declarations, host aspects,
  or user bindings under den.hosts.
---

## When This Skill Triggers

You are creating or modifying host declarations or host-specific aspects.

## Quick Rules

1. **One host declaration** per `den.hosts.<system>.<hostname>` entry in `modules/hosts.nix`
2. **User binding** via `den.hosts.<system>.<hostname>.users.<user> = { }` — assigns a user to the host
3. **Host aspect** — a separate `.nix` file with boot, filesystem, and hardware config for the specific host
4. **Default includes** wire shared aspects to all hosts via `den.default.includes`
5. **Architecture** must be one of: `x86_64-linux`, `aarch64-linux`, `aarch64-darwin`

## Den Hosts Syntax

### Declare a host with a user
```nix
# modules/hosts.nix
{
  den.hosts.x86_64-linux.myhost.users.admin = { };
}
```

### Host aspect with boot and filesystem
```nix
# modules/community/ocd/myhost.nix — or modules/<infra>/myhost.nix
{ den, ... }:
{
  den.aspects.myhost = {
    includes = [ <ocd.bootloader> <ocd.networking> ];
    nixos = {
      boot.loader.systemd-boot.enable = true;
      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };
    };
  };
}
```

### User aspect binding
```nix
# modules/<user>/profile.nix
{
  den.aspects.<user>-profile = {
    includes = [ <den.provides.primary-user> ];
    homeManager = { ... };
  };
}
```

### Standalone home-manager (macOS)
```nix
den.homes.aarch64-darwin.<user> = { aspect = "<user>-profile"; };
```

## Current Hosts

The project currently declares one host:

```nix
# modules/hosts.nix
den.hosts.x86_64-linux.ocd-dev.users.admin = { };
```

`ocd-dev` is a placeholder host for CI validation — fake boot/fs config, no real deployment target.

## Detailed References

- [Stack reference](../../context/stack.context.md)
- [Dendritic instructions](../../instructions/dendritic.instructions.md)
