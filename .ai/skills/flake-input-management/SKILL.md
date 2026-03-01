---
name: flake-input-management
description: |
  Flake input declaration and regeneration patterns via flake-file.
  Use when adding, updating, or removing flake inputs.
---

## When This Skill Triggers

You are adding, updating, or removing a flake input.

## Quick Rules

1. **Declare inputs in modules** — use `flake-file.inputs.<name>.url` in the aspect that needs the input, not in `flake.nix` directly
2. **Regenerate after changes** — run `nix run .#write-flake` (Linux) or `nix build .#write-flake && cp result/bin/write-flake flake.nix` (macOS) to update `flake.nix`
3. **Lock after regeneration** — `nix flake update <input-name>` to pin the new input in `flake.lock`
4. **Follow nixpkgs** — transitive inputs that depend on nixpkgs should declare `inputs.nixpkgs.follows = "nixpkgs"`
5. **Never hand-edit `flake.nix`** — it is generated from module options; manual edits will be overwritten and fail `check-flake-file`

## Adding an Input

### Declare in the consuming aspect
```nix
# modules/<namespace>/<name>.nix
{ inputs, ... }:
{
  flake-file.inputs.new-dep = {
    url = "github:owner/repo";
    inputs.nixpkgs.follows = "nixpkgs";  # if it uses nixpkgs
  };

  # Use the input
  ocd.<name>.nixos = {
    imports = [ inputs.new-dep.nixosModules.default ];
    # ...
  };
}
```

### Regenerate and lock
```bash
# Linux
nix run .#write-flake

# macOS (GNU cp flags fail in sandbox)
nix build .#write-flake
cp result/bin/write-flake flake.nix

# Lock the new input
nix flake update new-dep

# Verify
nix flake check
```

## Input Patterns in This Repo

| Aspect | Input | Purpose |
|--------|-------|---------|
| `dendritic.nix` | `nixpkgs`, `den`, `flake-file` | Core framework |
| `home-manager.nix` | `home-manager` | Home Manager module system |
| `context-compile-inputs.nix` | `nuenv`, `promptyst` | Context pipeline build tools |
| `lessuseless/jujutsu.nix` | `jjui` | Jujutsu TUI |

Inputs declared in separate aspects are merged by flake-file and written to a single `flake.nix`.

## Detailed References

- [Stack reference](../../context/stack.context.md)
- [Platform notes](../../context/platform-notes.context.md)
