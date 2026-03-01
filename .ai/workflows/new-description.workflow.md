---
description: "Create an aspect description TOML for the context-compile pipeline"
mode: agent
agent: nix-aspect-author
---

## Phase 1: Identify Aspect
1. Find the `.nix` source file for the target aspect
2. Check `_helpers/descriptions/` for an existing description TOML
3. Confirm the aspect ID (e.g. `ocd.networking`, `lessuseless.jujutsu`)

**CHECKPOINT**: Confirm the aspect ID and that no description TOML already exists.

## Phase 2: Analyze Aspect
1. Read the Nix source to understand what the aspect configures
2. Extract context entries (key facts about configuration, ports, paths, etc.)
3. Identify constraints (security, correctness, operational, portability)
4. Identify steps (what the aspect does in sequence)
5. Identify inputs and output schema fields if applicable

## Phase 3: Author Description
1. Create `modules/community/ocd/_helpers/descriptions/<name>.toml`
2. Add `[aspect]` header with id, version, and role
3. Add `[context]` with `[[context.entries]]` for key facts
4. Add `[[constraints]]` with text and severity
5. Add `[[steps]]` for procedural steps
6. Add `[[inputs]]` and `[schema]` with `[[schema.fields]]` if the aspect has clear inputs/outputs
7. Add `[[checkpoints]]` for critical verification points

## Phase 4: Verify
1. `jj file track` the new description TOML
2. Run `nix run .#write-context-docs` to render the Markdown output
3. `jj file track` all generated outputs
4. Run `nix flake check` to verify the description renders and staleness checks pass
5. Review the rendered Markdown in `.ai/output/` for completeness
