# Context-Compile Pipeline Reference

On-demand reference for the context-compile build pipeline. Load when you need to understand how aspect descriptions and PROSE primitives are rendered, or when debugging build failures.

## Pipeline Overview

```
Description TOMLs  ──┐
PROSE source TOMLs ──┤──→ nuenv (Nushell) ──→ Typst query ──→ rendered Markdown
Typst templates    ──┤                                         ├── .ai/output/*.md
promptyst package  ──┘                                         ├── .ai/AGENTS.md
                                                               ├── .ai/{type}/AGENTS.md
                                                               ├── .ai/{type}/*.{type}.md
                                                               ├── .ai/skills/{name}/SKILL.md
                                                               └── .github/{type}/*.ref.*.md
```

## Inputs

| Input | Source | Purpose |
|-------|--------|---------|
| `nuenv` | `github:xav-ie/nuenv` | Nushell-based `mkDerivation` — runs `.nu` build scripts |
| `promptyst` | `github:blessuselessk/promptyst` | Typst DSL for structured prompts (`flake=false`) |
| `treefmt-nix` | `github:numtide/treefmt-nix` | Formatting checks (not directly in pipeline, but validates output) |

Inputs are declared in `modules/community/ocd/context-compile-inputs.nix` (separate from the pipeline itself for modularity).

## Environment Variables

The nuenv derivation sets these env vars for `extract-and-render.nu`:

| Variable | Value | Purpose |
|----------|-------|---------|
| `RENDER_TEMPLATE` | `./render-aspect.typ` | Typst template for aspect descriptions |
| `PROSE_RENDER_TEMPLATE` | `./render-prose.typ` | Typst template for PROSE primitives |
| `AGENTS_TEMPLATE` | `./render-agents-md.typ` | Typst template for top-level AGENTS.md |
| `PRIMITIVE_AGENTS_TEMPLATE` | `./render-primitive-agents-md.typ` | Typst template for per-directory AGENTS.md |
| `PROMPTYST_PACKAGE_PATH` | `${promptystPackagePath}` | linkFarm for `@local/promptyst:0.2.0` resolution |
| `DESCRIPTIONS_DIR` | `${descriptions}` | Nix store path to `_helpers/descriptions/` |
| `PROSE_AGENTS_DIR` | `${proseAgents}` | Nix store path to `.ai/agents/` |
| `PROSE_INSTRUCTIONS_DIR` | `${proseInstructions}` | Nix store path to `.ai/instructions/` |
| `PROSE_SKILLS_DIR` | `${proseSkills}` | Nix store path to `.ai/skills/` |
| `PROSE_WORKFLOWS_DIR` | `${proseWorkflows}` | Nix store path to `.ai/workflows/` |
| `COMPOSABILITY_SCHEMA` | `${composabilitySchema}` | YAML schema for AGENTS.md composability section |
| `AGENTS_HEADER` | `${agentsHeader}` | Hand-authored AGENTS.md header file |

## Typst Query Pattern

The pipeline uses `typst query` (not `typst compile`) to extract rendered Markdown as a JSON string:

```bash
TYPST_PACKAGE_PATH=$PROMPTYST_PACKAGE_PATH \
  typst query --root . $TEMPLATE "<output>" --field value --one \
    --input "data-path=./staged-file.toml" \
    --input "format=toml"
```

Key points:

- `--root .` means Typst resolves `read()` calls relative to the build directory
- TOML files must be staged into the build dir (Typst cannot read from nix store paths directly via `read()`)
- `<output>` is a metadata label placed by the Typst template
- `--field value --one` extracts the string content from the query result

## Staging Gotchas

1. **Store paths vs working dir**: `DESCRIPTIONS_DIR` points to a nix store path. nuenv flattens `src` files to the build root but doesn't recursively copy store-path dirs. The build script uses `open --raw | save` to stage files.

1. **Skill TOML collisions**: All skill sources are named `SKILL.toml`. The build script prefixes with the parent directory name when staging (e.g., `context-compression-SKILL.toml`) to avoid overwriting.

1. **macOS sandbox**: nuenv on macOS cannot use GNU `cp` flags for nested store paths. Use Nushell's `open --raw | save` instead.

## Output Structure

After `nix run .#write-context-docs`:

```
.ai/
├── AGENTS.md                          # Header + generated composability
├── output/
│   ├── networking.md                  # Rendered aspect descriptions
│   ├── boot.md
│   ├── defaults.md
│   └── ...
├── agents/
│   ├── AGENTS.md                      # Per-primitive directory AGENTS.md
│   └── *.agent.md                     # Rendered agent primitives
├── instructions/
│   ├── AGENTS.md
│   └── *.instructions.md
├── skills/
│   ├── AGENTS.md
│   └── {name}/SKILL.md               # Rendered skill primitives
├── workflows/
│   ├── AGENTS.md
│   └── *.workflow.md
└── context/
    └── AGENTS.md

.github/
├── agents/
│   └── *.ref.agent.md                # Ref pointers (frontmatter + link)
├── instructions/
│   └── *.ref.instructions.md
├── skills/
│   └── *.ref.skill.md
└── workflows/
    └── *.ref.workflow.md
```

## Staleness Checks

Two checks run during `nix flake check`:

### `checks.context-docs-fresh`

Compares every file in the build output against the installed tree byte-for-byte using `diff -q`. Covers:

- `.ai/output/*.md` (aspect descriptions)
- `.ai/AGENTS.md` (top-level)
- `.ai/{type}/AGENTS.md` (per-primitive)
- `.ai/{type}/*.{type}.md` (rendered PROSE)
- `.ai/skills/{name}/SKILL.md` (rendered skills)
- `.github/{type}/*.ref.*.md` (ref pointers)

Fix: `nix run .#write-context-docs`

### `checks.dep-refs-fresh`

Parses `.ai/context/references/deps/manifest.toml` for dependency names and verifies each has a corresponding `.md` file in the same directory.

Fix: `nix run .#update-dep-refs`

### `checks.context-compile`

Simply builds the `contextDocs` derivation — verifies all templates render without errors.

## Adding New Descriptions

1. Create a `.toml` file in `modules/community/ocd/_helpers/descriptions/`
1. Use `[aspect]` + `[context]` for minimal descriptions, or add `[[constraints]]`, `[[steps]]`, `[[inputs]]`, `[schema]`, `[[checkpoints]]` for full descriptions
1. `git add` the new file (flakes require tracked files)
1. Run `nix run .#write-context-docs` to render
1. Commit both the TOML source and rendered output

No changes to `context-compile.nix` needed — glob-based discovery finds new files automatically.

## Adding New PROSE Primitives

1. Create the TOML source in the appropriate directory with the correct naming convention
1. `git add` the file
1. Run `nix run .#write-context-docs`
1. Commit source + rendered output + ref pointer

| Type | Location | Naming |
|------|----------|--------|
| Agent | `.ai/agents/` | `{id}.agent.toml` |
| Instruction | `.ai/instructions/` | `{id}.instructions.toml` |
| Skill | `.ai/skills/{name}/` | `SKILL.toml` |
| Workflow | `.ai/workflows/` | `{id}.workflow.toml` |
