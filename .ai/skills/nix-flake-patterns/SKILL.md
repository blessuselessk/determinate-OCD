---
name: nix-flake-patterns
description: |
  Den framework and flake-parts conventions for NixOS aspect authoring.
  Use when creating or modifying files under modules/. Provides quick
  reference for den syntax, import-tree rules, and aspect composition.
---

## When This Skill Triggers

You are creating or modifying a `.nix` file under `modules/`.

## Quick Rules

1. **One aspect per file** — filename is the aspect name
2. **No `default.nix`** under `modules/` — import-tree auto-discovers
3. **No `specialArgs`** — share values via `let`, module options, or `config`
4. **`/_` infix** in path excludes from import-tree (use for helpers, data)

## Den Syntax

### Aspect classes
```nix
ocd.<name>.nixos = { ... };        # NixOS system config
ocd.<name>.homeManager = { ... };  # Home Manager user config
ocd.<name>.darwin = { ... };       # macOS config
```

### Composition
```nix
ocd.<name> = {
  includes = [ <ocd.networking> <ocd.boot> ];
  nixos = { ... };
};
```

### Sub-aspects (provides)
```nix
ocd.<name>.provides = {
  hw.includes = [ <ocd.bootloader> ];
  vm.includes = [ <ocd.installer> ];
};
# Consumed as: <<ocd.name>/hw>
```

### Hosts
```nix
den.hosts.x86_64-linux.<hostname>.users.<user> = { };
```

### Standalone home-manager
```nix
den.homes.aarch64-darwin.<user> = { aspect = "<user>-profile"; };
```

### Namespaces
```nix
imports = [ (inputs.den.namespace "ocd" true) ];  # community (exposed)
imports = [ (inputs.den.namespace "<user>" false) ];  # personal
```

### Flake inputs (via flake-file)
```nix
flake-file.inputs.<name>.url = "github:owner/repo";
# Then: nix run .#write-flake to regenerate flake.nix
```

## Detailed References

- [Dendritic instructions](../../instructions/dendritic.instructions.md)
- [Stack reference](../../context/stack.context.md)
