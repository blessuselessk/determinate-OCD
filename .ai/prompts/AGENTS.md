# prompts/

> Reusable phased workflow invoked on demand. The primary orchestrator of execution — activates agents, references knowledge, produces output.

## Tier: active

**Can**: invoke, reference, produce, auto-load

## File Pattern

`*.prompt.md`

## Frontmatter

**Required**: `description`

**Optional**: `mode`, `agent`, `model`, `tools`, `mcp`, `input`

## Outbound Edges

- → **agent**: activates (invoke)
- → **context**: references (reference)
- → **memory**: reads (reference)
- → **memory**: updates (produce)
- → **spec**: consumes (reference)
- → **spec**: produces (produce)
- → **instruction**: references (reference)
- → **instruction**: updates (produce)
- → **prompt**: chains-to (invoke)

## Inbound Edges

- ← **prompt**: chains-to (invoke)

## Prohibited

- Cannot **hands-off-to** agent: Only agents can declare handoffs. Prompts activate agents via mode/agent frontmatter, but cannot hand off between them.
- **instruction** cannot **invoke** this: Instructions are passive rules. They are injected into agents via applyTo, they never invoke or execute anything.
- **context** cannot **invoke** this: Context is pure reference knowledge. No outbound edges except cross-references to other context files.
- **memory** cannot **invoke** this: Memory is pure state. It is written to and read from, but never initiates any action.
- **spec** cannot **invoke** this: Specs are blueprints consumed by prompts. They cannot invoke agents or trigger execution.
- **skill** cannot **invoke** this: Skills describe capabilities for auto-discovery. They do not directly execute prompts or load instructions. Agents mediate.

