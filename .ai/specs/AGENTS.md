# specs/

> Implementation-ready blueprint. Consumed by prompts as input, produced by specification workflows as output. Never invokes anything.

## Tier: passive

**Can**: reference

**Cannot**: invoke, produce

## File Pattern

`*.spec.md`

## Frontmatter

**Optional**: `description`

## Inbound Edges

- ← **prompt**: consumes (reference)
- ← **prompt**: produces (produce)

## Prohibited

- Cannot **invoke** agent, prompt, instruction, skill: Specs are blueprints consumed by prompts. They cannot invoke agents or trigger execution.
- **context** cannot **invoke** this: Context is pure reference knowledge. No outbound edges except cross-references to other context files.
- **memory** cannot **invoke** this: Memory is pure state. It is written to and read from, but never initiates any action.
- **agent** cannot **consumes** this: Agents do not directly consume specs. Prompts mediate the spec-to-agent path.

