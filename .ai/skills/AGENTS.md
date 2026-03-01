# skills/

> Packaged capability for distribution and auto-discovery. Contains references, scripts, and assets. Agents auto-summon skills based on description match to current task.

## Tier: meta

**Can**: reference, auto-load

**Cannot**: invoke

## File Pattern

`SKILL.md`

## Frontmatter

**Required**: `name`, `description`

**Optional**: `license`, `allowed-tools`, `metadata`

## Outbound Edges

- → **context**: references (reference)

## Inbound Edges

- ← **agent**: auto-discovers (auto-load)

## Prohibited

- Cannot **invoke** prompt, instruction: Skills describe capabilities for auto-discovery. They do not directly execute prompts or load instructions. Agents mediate.
- **instruction** cannot **invoke** this: Instructions are passive rules. They are injected into agents via applyTo, they never invoke or execute anything.
- **context** cannot **invoke** this: Context is pure reference knowledge. No outbound edges except cross-references to other context files.
- **memory** cannot **invoke** this: Memory is pure state. It is written to and read from, but never initiates any action.
- **spec** cannot **invoke** this: Specs are blueprints consumed by prompts. They cannot invoke agents or trigger execution.

