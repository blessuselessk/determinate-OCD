# memory/

> Decision log persisting across sessions. Written to by active primitives after execution. Read on demand. Never invokes anything.

## Tier: passive

**Can**: reference

**Cannot**: invoke, produce

## File Pattern

`*.memory.md`

## Inbound Edges

- ← **agent**: reads (reference)
- ← **agent**: updates (produce)
- ← **prompt**: reads (reference)
- ← **prompt**: updates (produce)
- ← **instruction**: references (reference)

## Prohibited

- Cannot **invoke** agent, prompt, instruction, context, spec, skill: Memory is pure state. It is written to and read from, but never initiates any action.
- **context** cannot **invoke** this: Context is pure reference knowledge. No outbound edges except cross-references to other context files.

