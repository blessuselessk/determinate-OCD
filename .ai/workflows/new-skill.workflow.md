---
description: "Create a new PROSE skill primitive"
mode: agent
agent: prose-author
---

## Phase 1: Scope
1. Identify the capability this skill provides and when it activates
2. Check existing skills in `.ai/skills/` for overlap
3. Choose a kebab-case name for the skill directory: `.ai/skills/<name>/`

**CHECKPOINT**: Confirm the skill name, trigger condition, and purpose before authoring.

## Phase 2: Author
1. Create directory `.ai/skills/<name>/`
2. Create `SKILL.toml` with `[skill]` header: name, description, trigger, rules
3. Add `[[skill.extra-sections]]` for extended reference content if needed
4. Add `[[skill.references]]` — note paths use `../../` from skill subdirectories

## Phase 3: Validate
1. Confirm meta tier: no invocation verbs (`activates`, `hands-off-to`, `spawns`)
2. Verify trigger is a clear, testable condition
3. Verify rules are actionable and imperative
4. Check that all reference paths resolve to existing files

## Phase 4: Integrate
1. `jj file track` the new `SKILL.toml` file
2. Run `nix run .#write-context-docs` to render the Markdown output
3. `jj file track` all generated outputs (rendered `SKILL.md`, ref pointers)
4. Run `nix flake check` to verify staleness checks pass
