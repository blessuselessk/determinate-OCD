---
description: "Create a new PROSE workflow primitive"
mode: agent
agent: prose-author
---

## Phase 1: Scope
1. Identify the task this workflow guides
2. Check existing workflows in `.ai/workflows/` for overlap
3. Choose an ID: `<task>.workflow.toml`
4. Determine which agent should execute this workflow

**CHECKPOINT**: Confirm the workflow ID, executing agent, and purpose before designing phases.

## Phase 2: Design Phases
1. Break the task into 3–5 sequential phases
2. Place checkpoints after information-gathering phases (before irreversible actions)
3. Ensure the final phase includes verification steps

## Phase 3: Author
1. Create `.ai/workflows/<id>.workflow.toml` with `[workflow]` header
2. Define `[[workflow.phases]]` with name, steps, and optional checkpoint
3. Verify the final phase includes a `nix flake check` or equivalent verification step

## Phase 4: Integrate
1. `jj file track` the new `.workflow.toml` file
2. Run `nix run .#write-context-docs` to render the Markdown output
3. `jj file track` all generated outputs (rendered `.md`, ref pointers)
4. Run `nix flake check` to verify staleness checks pass
