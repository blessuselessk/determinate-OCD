# instructions/

> Persistent rules scoped by file glob. Automatically injected into agents when working on matching files. Never invokes anything.

## Tier: passive

**Can**: reference

**Cannot**: invoke, produce

## File Pattern

`*.instructions.md`

## Frontmatter

**Required**: `applyTo`

**Optional**: `description`

## Outbound Edges

- → **context**: references (reference)
- → **memory**: references (reference)
- → **agents_md**: compiles-into (produce)

## Inbound Edges

- ← **agent**: auto-loads (auto-load)
- ← **prompt**: references (reference)
- ← **prompt**: updates (produce)

## Prohibited

- Cannot **invoke** agent, prompt, skill: Instructions are passive rules. They are injected into agents via applyTo, they never invoke or execute anything.
- **context** cannot **invoke** this: Context is pure reference knowledge. No outbound edges except cross-references to other context files.
- **memory** cannot **invoke** this: Memory is pure state. It is written to and read from, but never initiates any action.
- **spec** cannot **invoke** this: Specs are blueprints consumed by prompts. They cannot invoke agents or trigger execution.
- **skill** cannot **invoke** this: Skills describe capabilities for auto-discovery. They do not directly execute prompts or load instructions. Agents mediate.

