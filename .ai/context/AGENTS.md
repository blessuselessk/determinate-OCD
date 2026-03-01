# context/

> Reference knowledge loaded on demand via markdown links. Pure data — no outbound edges except to other context files.

## Tier: passive

**Can**: reference

**Cannot**: invoke, produce

## File Pattern

`*.context.md`

## Frontmatter

**Optional**: `description`

## Outbound Edges

- → **context**: references (reference)

## Inbound Edges

- ← **agent**: references (reference)
- ← **prompt**: references (reference)
- ← **instruction**: references (reference)
- ← **context**: references (reference)
- ← **skill**: references (reference)

## Prohibited

- Cannot **invoke** agent, prompt, instruction, memory, spec, skill: Context is pure reference knowledge. No outbound edges except cross-references to other context files.
- **memory** cannot **invoke** this: Memory is pure state. It is written to and read from, but never initiates any action.

