# determinate-OCD — Copilot Instructions

NixOS flake: Determinate + OpenClaw + Dendrix. See [AGENTS.md](../AGENTS.md) for project principles.

## Environment

- This is a Nix flake project. Use `nix flake check` to validate changes.
- All config files are `.nix` under `modules/`. Each file is one aspect (feature).
- No `npm`, `pip`, or other package managers — everything is managed by Nix.

## Key rules

- One aspect per `.nix` file. Filename = aspect name.
- No `specialArgs` or `extraSpecialArgs`.
- Secrets are always file paths (`config.age.secrets.<name>.path`), never inline.
- Use `den` namespace syntax: `ocd.<name>.nixos = { ... }` for community aspects.

## References

- [Dendritic pattern rules](instructions/dendritic.instructions.md) — how to write aspects
- [Stack reference](context/stack.context.md) — dependency map and API reference
- [Architectural decisions](memory/decisions.memory.md) — why things are the way they are
