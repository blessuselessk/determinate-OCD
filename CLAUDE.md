# determinate-OCD

NixOS flake: Determinate + OpenClaw + Dendrix. See [AGENTS.md](AGENTS.md) for project principles.

## Quick orientation

- `modules/` — Dendritic aspects (one `.nix` file = one feature). [Rules](/.github/instructions/dendritic.instructions.md)
- `nix/hosts/` — Traditional NixOS host configs
- `.github/` — PROSE primitives, CI workflows
- `_context/` — Generated data artifacts (excluded from `import-tree` via `/_`)

## Stack

See [stack reference](/.github/context/stack.context.md) for the full dependency map and API reference. The short version:

- **den** — aspect framework (`den.hosts`, `den.default.includes`, angle-bracket syntax)
- **import-tree** — auto-imports `modules/**/*.nix`, excludes `/_` paths
- **flake-parts** — module system glue
- **agenix** — secrets by file path

## Aspect authoring

When creating or modifying aspects, follow [dendritic instructions](/.github/instructions/dendritic.instructions.md). Key points:

- One aspect per file, filename = aspect name
- Use `ocd.<name>.nixos = { ... }` for community aspects
- Compose with `includes`, decompose with `provides`
- No `specialArgs`, no `default.nix` under `modules/`

## Common tasks

- **New aspect**: Create `modules/community/ocd/<name>.nix` with `ocd.<name>.<class> = { ... };`
- **New host**: Add `den.hosts.<system>.<hostname>` in `modules/<infra>/hosts.nix`
- **New secret**: Encrypted file in `modules/<user>/secrets/`, wire via `config.age.secrets.<name>.path`
- **Build (CI)**: Push to GitHub — GHA runs `nix flake check` and `nix build`
- **Build ISO**: `nix build .#nixosConfigurations.iso.config.system.build.isoImage`
- **Remote deploy**: `fh apply nixos "org/flake/*#nixosConfigurations.<hostname>"`
- **Regenerate flake.nix**: `nix run .#write-flake`

## Namespace guide

| Namespace | Path | What belongs here |
|-----------|------|-------------------|
| `ocd` | `modules/community/ocd/` | OCD-stack-coupled: OpenClaw wiring, Determinate boot, networking |
| `<user>` | `modules/<user>/` | Personal: shell, git, editors, desktop, secrets |
| `<infra>` | `modules/<infra>/` | System: hosts, nix-settings, workstation, state-version |
