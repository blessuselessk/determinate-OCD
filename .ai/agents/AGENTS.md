# agents/

> Role-based persona with bounded tool access and optional handoffs. The top-level orchestrator in the composition hierarchy.

## Tier: active

**Can**: invoke, reference, produce, auto-load

## File Pattern

`*.agent.md`

## Frontmatter

**Required**: `description`

**Optional**: `tools`, `handoffs`, `model`

## Outbound Edges

- → **agent (other)**: hands-off-to (invoke) — Sequential delegation — agent A completes its phase, passes context to agent B. Not self-referential.
- → **agent (other)**: spawns (invoke) — Parent-child — agent A creates a scoped subagent for a subtask, receives result back. Concurrent.
- → **instruction**: auto-loads (auto-load)
- → **context**: references (reference)
- → **memory**: reads (reference)
- → **memory**: updates (produce)
- → **skill**: auto-discovers (auto-load)
- → **agents_md**: inherits (auto-load)

## Inbound Edges

- ← **agent**: hands-off-to (invoke)
- ← **agent**: spawns (invoke)
- ← **prompt**: activates (invoke)
- ← **agents_md**: inherited-by (auto-load)

## Prohibited

- Cannot **consumes** spec: Agents do not directly consume specs. Prompts mediate the spec-to-agent path.
- **instruction** cannot **invoke** this: Instructions are passive rules. They are injected into agents via applyTo, they never invoke or execute anything.
- **context** cannot **invoke** this: Context is pure reference knowledge. No outbound edges except cross-references to other context files.
- **memory** cannot **invoke** this: Memory is pure state. It is written to and read from, but never initiates any action.
- **spec** cannot **invoke** this: Specs are blueprints consumed by prompts. They cannot invoke agents or trigger execution.
- **prompt** cannot **hands-off-to** this: Only agents can declare handoffs. Prompts activate agents via mode/agent frontmatter, but cannot hand off between them.

