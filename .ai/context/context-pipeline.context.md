______________________________________________________________________

## description: "Context-compile pipeline — nuenv + Typst rendering architecture, env vars, failure modes"

# Context Pipeline Reference

End-to-end reference for the context-compile pipeline that renders TOML sources into Markdown. Load when debugging build failures, adding new descriptions, or modifying the pipeline itself.

## Architecture

```
TOML sources ──→ nuenv (Nushell mkDerivation) ──→ typst query ──→ rendered Markdown
                       │                                │
                       ├── extract-and-render.nu         ├── .ai/output/*.md
                       ├── render-aspect.typ             ├── .ai/AGENTS.md
                       ├── render-prose.typ              ├── .ai/{type}/*.{type}.md
                       ├── render-agents-md.typ          ├── .ai/skills/{name}/SKILL.md
                       └── render-primitive-agents-md.typ├── .ai/{type}/AGENTS.md
                                                        └── .github/{type}/*.ref.*.md
```

## Source Locations

| What | Path |
|------|------|
| Build script | `modules/community/ocd/_helpers/extract-and-render.nu` |
| Aspect template | `modules/community/ocd/_helpers/render-aspect.typ` |
| PROSE template | `modules/community/ocd/_helpers/render-prose.typ` |
| AGENTS.md template | `modules/community/ocd/_helpers/render-agents-md.typ` |
| Per-dir AGENTS.md template | `modules/community/ocd/_helpers/render-primitive-agents-md.typ` |
| Nix entry point | `modules/community/ocd/context-compile.nix` |
| Input declarations | `modules/community/ocd/context-compile-inputs.nix` |

## Environment Variables

The nuenv derivation sets these for `extract-and-render.nu`:

| Variable | Purpose |
|----------|---------|
| `RENDER_TEMPLATE` | Typst template for aspect descriptions (`./render-aspect.typ`) |
| `PROSE_RENDER_TEMPLATE` | Typst template for PROSE primitives (`./render-prose.typ`) |
| `AGENTS_TEMPLATE` | Typst template for top-level AGENTS.md |
| `PRIMITIVE_AGENTS_TEMPLATE` | Typst template for per-directory AGENTS.md |
| `PROMPTYST_PACKAGE_PATH` | linkFarm path for `@local/promptyst:0.2.0` resolution |
| `DESCRIPTIONS_DIR` | Nix store path to `_helpers/descriptions/` |
| `PROSE_AGENTS_DIR` | Nix store path to `.ai/agents/` |
| `PROSE_INSTRUCTIONS_DIR` | Nix store path to `.ai/instructions/` |
| `PROSE_SKILLS_DIR` | Nix store path to `.ai/skills/` |
| `PROSE_WORKFLOWS_DIR` | Nix store path to `.ai/workflows/` |
| `COMPOSABILITY_SCHEMA` | YAML schema for AGENTS.md composability section |
| `AGENTS_HEADER` | Hand-authored AGENTS.md header file |

## Render Paths

### Aspect descriptions

Source: `_helpers/descriptions/*.{toml,yaml}` → Template: `render-aspect.typ` → Output: `.ai/output/*.md`

Routing by sections present:

| Condition | Renderer | Output |
|-----------|----------|--------|
| All 6 sections + checkpoints | `render-prompt()` | Full structured prompt |
| `context` section present | `render-context()` | Context reference card |
| `schema` only | `render-schema()` | Schema definition |
| Fallback | Raw heading | `# <aspect.id>` |

### PROSE primitives

Source: `.ai/{type}/*.{type}.toml` → Template: `render-prose.typ` → Output: `.ai/{type}/*.{type}.md` + `.github/{type}/*.ref.*.md`

Skills are special: source is `.ai/skills/{name}/SKILL.toml`, output is `.ai/skills/{name}/SKILL.md`.

### AGENTS.md files

- **Top-level**: Header from `AGENTS.md.header` + generated composability from `render-agents-md.typ`
- **Per-directory**: One `AGENTS.md` per primitive type dir, generated from `render-primitive-agents-md.typ`

## Typst Query Pattern

```bash
TYPST_PACKAGE_PATH=$PROMPTYST_PACKAGE_PATH \
  typst query --root . $TEMPLATE "<output>" --field value --one \
    --input "data-path=./staged-file.toml" \
    --input "format=toml"
```

- `--root .` — Typst `read()` resolves relative to build dir
- Files must be staged into build dir (Typst cannot read nix store paths via `read()`)
- `<output>` — metadata label placed by the template
- `--field value --one` — extracts string content from query result

## Failure Modes

### SKILL.toml staging collisions

All skill sources are named `SKILL.toml`. The build script prefixes with parent dir name when staging (e.g., `host-declarations-SKILL.toml`). If two skills share a parent dir name, they'll collide.

### Missing files in sandbox

New TOML sources must be `git add`ed before `nix flake check` — flakes only see tracked files. The build will silently skip untracked sources (glob returns nothing).

### Staleness check mismatches

`checks.context-docs-fresh` does byte-for-byte diff of every generated file. Any manual edit to rendered `.md` files will fail this check. Fix: `nix run .#write-context-docs`.

### macOS sandbox issues

nuenv on macOS cannot use GNU `cp` flags for nested store paths. The build script uses Nushell's `open --raw | save` instead. See [platform notes](platform-notes.context.md).

## Key Commands

| Command | Purpose |
|---------|---------|
| `nix run .#write-context-docs` | Render all outputs and install to working tree |
| `nix run .#update-dep-refs` | Fetch/update dependency reference docs |
| `nix build .#context-docs` | Build the derivation without installing |
| `nix flake check` | Run all checks including staleness |

## Adding New Content

### New aspect description

1. Create `.toml` in `modules/community/ocd/_helpers/descriptions/`
1. `git add` or `jj file track` the file
1. `nix run .#write-context-docs`
1. Track generated output

### New PROSE primitive

1. Create TOML source in the correct type directory with naming convention
1. Track the file
1. `nix run .#write-context-docs`
1. Track rendered `.md` + ref pointer

No changes to `context-compile.nix` needed — glob-based discovery finds new files automatically.
