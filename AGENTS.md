# determinate-OCD

**Determinate-NixOS · OpenClaw · Dendrix**

A Nix flake that builds a NixOS system with three pillars:

- **Determinate** — Builds on Determinate Systems NixOS (flakes enabled, FlakeHub CLI, remote deploy)
- **OpenClaw** — AI gateway as systemd user service (Telegram bridge, plugins managed by Nix)
- **Dendrix** — Aspect-oriented config (one `.nix` file per feature, auto-imported by `import-tree`)

## Principles

### One aspect, one file

Every `.nix` file under `modules/` is a self-contained flake-parts module for one cross-cutting feature. The filename is the aspect name. No monolithic config files.

### No specialArgs

Never use `specialArgs` or `extraSpecialArgs`. Share values via `let`, module options, or top-level configuration.

### Secrets by path, never inline

Secrets are encrypted at rest (agenix), decrypted at activation, and referenced by file path (`config.age.secrets.<name>.path`). Never put secrets in Nix code or the Nix store.

### Explicit wiring

Be explicit about dependencies and configurations. Do not rely on hidden state. When using `den`, compose via named `includes` lists.

### Verify before apply

AI-initiated modifications must pass verification gates before taking effect:

1. `nix flake check` (syntax/evaluation)
1. Dry-run build (preview without applying)
1. Diff against current generation
1. Record rationale in changelog

### Three namespaces

| Namespace | Path | Visibility | Contains |
|-----------|------|------------|----------|
| `ocd` | `modules/community/ocd/` | Public (Dendrix-shareable) | OCD-stack-coupled aspects |
| `<user>` | `modules/<user>/` | Private | Personal config, secrets, dotfiles |
| `<infra>` | `modules/<infra>/` | Private | Host declarations, system settings |

### Path conventions

| Convention | Meaning |
|------------|---------|
| `/_` infix in path | Excluded by `import-tree` (helpers, context, data) |
| `+flag` prefix | Dendrix opt-in group (e.g. `+iso/`) |
| `private` infix | Excluded by Dendrix community pipeline, loaded by own flake |

## Domain structure

- `modules/` — Dendritic aspects (auto-imported by `import-tree`)
- `nix/hosts/` — Traditional NixOS host configs (bridged via `non-dendritic.nix`)
- `_context/` — Generated data artifacts for AI agents (excluded from `import-tree`)
- `.github/` — PROSE primitives, CI workflows

## CI as build loop

This project is developed on macOS. NixOS builds are validated via GitHub Actions:

- `nix flake check` on every push
- `nix build` of the full system closure
- No local `nixos-rebuild` — CI is the feedback loop
