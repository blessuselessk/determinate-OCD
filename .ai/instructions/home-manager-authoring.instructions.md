---
applyTo: "modules/**/*.nix"
description: "Home Manager aspect authoring rules — homeManager class, user bindings, program patterns"
---

## Class Usage
- Use `<namespace>.<name>.homeManager = { ... }` for user-scoped config (dotfiles, programs, packages)
- Use `<namespace>.<name>.nixos = { ... }` for system-scoped config (services, users, networking)
- A single aspect can have both classes when they're tightly coupled

## User Binding
- Bind a user to a host via `den.hosts.<system>.<hostname>.users.<user> = { }`
- Create a user profile aspect with `den.provides.primary-user` for the default user
- For standalone home-manager (macOS): `den.homes.<system>.<user> = { aspect = "<user>-profile"; }`

## Program Configuration
Use `programs.<name>` for tools with Home Manager modules:

```nix
lessuseless.jujutsu.homeManager = { pkgs, ... }: {
  programs.jujutsu = {
    enable = true;
    settings = { ... };
  };
  home.packages = [ pkgs.lazyjj ];
};
```

The function form `{ pkgs, ... }:` gives access to `pkgs`, `config`, `lib`, and `inputs`.
Use `home.packages` for tools without dedicated modules.
Use `home.file` for dotfiles not managed by a `programs.*` module.

## Prohibited
- No `home.stateVersion` in individual aspects — set globally in `defaults.nix`
- No `users.users.<name>` in homeManager class — use nixos class for system-level user config
- No absolute paths to home directory — use `~` or `config.home.homeDirectory`

## References
- [Stack reference](../context/stack.context.md)
- [Dendritic instructions](dendritic.instructions.md)
