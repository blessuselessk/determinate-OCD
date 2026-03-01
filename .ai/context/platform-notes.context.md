______________________________________________________________________

## description: "Platform-specific gotchas — macOS sandbox, nuenv, Typst, file staging"

# Platform Notes

Tribal knowledge for platform-specific issues in the determinate-OCD build pipeline. Load when debugging build failures on macOS or when the nuenv/Typst pipeline behaves unexpectedly.

## macOS Sandbox

### GNU `cp` flags fail

GNU coreutils `cp -f` and other flags don't work in the macOS nix sandbox. For `write-flake`:

```bash
# WRONG — fails on macOS
cp -f $(nix build .#write-flake --print-out-paths)/bin/write-flake flake.nix

# RIGHT — build then plain cp
nix build .#write-flake
cp result/bin/write-flake flake.nix
```

### Nested store dir copy

nuenv on macOS cannot `cp` nested directories from the nix store. The build script works around this with Nushell's native I/O:

```nu
# WRONG — fails in macOS sandbox
cp $"($env.DESCRIPTIONS_DIR)/file.toml" ./staged.toml

# RIGHT — works everywhere
open $"($env.DESCRIPTIONS_DIR)/file.toml" --raw | save ./staged.toml
```

## nuenv Behavior

### File flattening

nuenv copies `src` files into the build root but flattens the directory structure. Files from nested `src` subdirectories end up at the build root. This is why `extract-and-render.nu` and all `.typ` templates are in the same `_helpers/` directory.

### Store path resolution

`DESCRIPTIONS_DIR` and all `PROSE_*_DIR` variables point to nix store paths (e.g., `/nix/store/abc...-descriptions`), not relative paths. The build script must stage files from these store paths into the working directory for Typst to access them.

## Typst

### `read()` resolution

Typst's `read()` function resolves paths relative to `--root` only. Files outside the `--root` directory (including nix store paths) cannot be read directly. All input files must be staged into the build directory before rendering.

### `typst query` vs `typst compile`

The pipeline uses `typst query` (not `compile`) to extract rendered Markdown as a JSON string. The template places a metadata label (`<output>`) that `--field value --one` extracts.

## SKILL.toml Staging

All skill TOML sources are named `SKILL.toml` (they live in separate directories: `.ai/skills/{name}/SKILL.toml`). When staging for the Typst build, the build script prefixes each with its parent directory name to avoid collisions:

```nu
# .ai/skills/nix-flake-patterns/SKILL.toml → nix-flake-patterns-SKILL.toml
# .ai/skills/host-declarations/SKILL.toml  → host-declarations-SKILL.toml
```

## Flake File Tracking

New files must be tracked by the VCS before Nix flakes can see them:

```bash
# Jujutsu (this project)
jj file track .ai/skills/new-skill/SKILL.toml

# Git fallback
git add .ai/skills/new-skill/SKILL.toml
```

Without tracking, `nix flake check` and `nix run .#write-context-docs` will silently skip the file (glob returns no matches for untracked files).
