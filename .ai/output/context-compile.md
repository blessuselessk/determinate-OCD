# Prompt: ocd.context-compile

**Version:** 0.1.0

## Role
Build pipeline — renders aspect descriptions and PROSE primitives via nuenv + Typst, produces context docs with staleness checks

## Context: context-compile-ctx
| Key | Value |
| --- | ----- |
| nuenv-overlay | pkgs.extend inputs.nuenv.overlays.default — provides nuenv.mkDerivation |
| promptyst-linkfarm | linkFarm "promptyst-packages" with local/promptyst/0.2.0 for TYPST_PACKAGE_PATH |
| description-sources | ./_helpers/descriptions/ — glob discovers *.toml and *.yaml aspect descriptions |
| prose-sources | Four directories: .ai/agents/*.agent.toml, .ai/instructions/*.instructions.toml, .ai/skills/*/SKILL.toml, .ai/workflows/*.workflow.toml |
| build-script | ./_helpers/extract-and-render.nu — Nushell glob-based build orchestrator |
| render-templates | render-aspect.typ (descriptions), render-prose.typ (PROSE primitives), render-agents-md.typ, render-primitive-agents-md.typ |
| outputs | packages.context-docs, packages.write-context-docs, packages.update-dep-refs |
| checks | checks.context-compile (build succeeds), checks.context-docs-fresh (installed files match build), checks.dep-refs-fresh (manifest entries have .md files) |
| write-context-docs | Shell script that installs rendered output to .ai/output/, .ai/AGENTS.md, per-primitive AGENTS.md, PROSE primitives, and .github/ ref pointers |
| scope | perSystem module — uses pkgs and inputs |

## Constraints
1. All description TOMLs must be in _helpers/descriptions/ for glob discovery
2. PROSE TOML sources must use exact naming conventions: *.agent.toml, *.instructions.toml, */SKILL.toml, *.workflow.toml
3. Staleness check compares installed .ai/ files byte-for-byte with build output — any mismatch fails nix flake check
4. nuenv sandbox on macOS cannot cp nested dirs from nix store — use open --raw | save instead
5. Skill TOMLs are all named SKILL.toml — build script prefixes with parent dir name to avoid staging collisions

## Steps
1. Extend pkgs with nuenv overlay and create promptyst linkFarm for TYPST_PACKAGE_PATH
2. Define contextDocs derivation: set env vars for all source dirs and templates, run extract-and-render.nu
3. Build extract-and-render.nu: glob description files, stage into Typst root, render via typst query
4. Generate AGENTS.md (header + composability section), per-primitive AGENTS.md files
5. Render PROSE primitives (agents, instructions, skills, workflows) and ref pointers
6. Define write-context-docs script to install outputs, update-dep-refs for dependency documentation
7. Define staleness checks: context-docs-fresh (diff all outputs) and dep-refs-fresh (manifest entries)

## Inputs
| Name | Type | Description |
| ---- | ---- | ----------- |
| nuenv | flake-input | Nushell-based derivation builder (provides nuenv.mkDerivation) |
| promptyst | path | Typst prompt DSL package (flake=false, used via linkFarm) |
| descriptions | directory | Path to _helpers/descriptions/ containing *.toml and *.yaml aspect descriptions |

## Output Schema: context-compile-output
| Field | Type | Description |
| ----- | ---- | ----------- |
| context-docs | derivation | Nix store path containing all rendered Markdown, TOML sources, AGENTS.md, PROSE primitives, and ref pointers |
| write-context-docs | derivation | Shell script to install rendered output into the working tree |
| staleness-check | bool | Whether installed files match the current build output |

## Checkpoint: verify-render
| Property | Value |
| -------- | ----- |
| after-step | 3 |
| assertion | Every description TOML in _helpers/descriptions/ produces a corresponding .md in the output |
| on-fail | halt |

## Checkpoint: verify-staleness
| Property | Value |
| -------- | ----- |
| after-step | 7 |
| assertion | nix flake check passes with checks.context-docs-fresh and checks.dep-refs-fresh |
| on-fail | halt |