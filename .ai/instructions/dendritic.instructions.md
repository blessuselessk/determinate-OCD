---
applyTo: "modules/**/*.nix"
description: "Dendritic aspect authoring rules for NixOS modules"
---

## Aspect Structure
- One aspect per file, filename is the aspect name
- Use `ocd.<name>.nixos = { ... }` for community aspects
- Use `<user>.<name>.nixos = { ... }` for personal aspects
- Compose with `includes`, decompose with `provides`

## Path Conventions
- `/_` infix in path: excluded by `import-tree` (helpers, context, data)
- `+flag` prefix: Dendrix opt-in group
- `private` infix: excluded from community pipeline

## Prohibited
- No `specialArgs` or `extraSpecialArgs`
- No `default.nix` under `modules/`
- No secrets in Nix code or the Nix store

## References
- [Stack reference](../context/stack.context.md)
