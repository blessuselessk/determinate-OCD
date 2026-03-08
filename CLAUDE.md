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
- **New secret**: Encrypted file in `modules/<user>/secrets/`, wire via `config.age.secrets.<name>.path`. Edit secrets with `ragenix` (or `nix run nixpkgs#ragenix -- ...` if not in PATH)
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

## Jujutsu (jj) aliases

The `lessuseless.jujutsu` aspect (`modules/lessuseless/jujutsu.nix`) defines these aliases:

| Alias | Expands to | Purpose |
|-------|-----------|---------|
| `s` | `jj show` | Show current commit |
| `l` | `jj log -r compared_to_trunk()` | Log of work-in-progress vs trunk |
| `ll` | `jj log -r ..` | Full visible history |
| `lr` | `jj log -r "default() & recent()"` | Recent commits in default set |
| `sq` | `jj squash -i` | Interactive squash into parent |
| `su` | `jj squash -i -f @ -t @+` | Interactive squash upward |
| `sd` | `jj squash -i -f @ -t @-` | Interactive squash downward |
| `sU` | `jj squash -i -f @+ -t @` | Pull from child into current |
| `sD` | `jj squash -i -f @- -t @` | Pull from parent into current |
| `tug` | `jj bookmark move --from closest_bookmark(@-) --to @-` | Advance nearest bookmark to parent |

Custom revset aliases: `trunk()` = `main@origin`, `compared_to_trunk()`, `default()`, `recent()` (last week), `closest_bookmark(to)`.

## OpenClaw

See [modules/community/ocd/CLAUDE.md](modules/community/ocd/CLAUDE.md) for OpenClaw troubleshooting and configuration guidance.
