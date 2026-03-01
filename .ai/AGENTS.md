# .ai/ — Agent Primitives

Platform-agnostic home for PROSE agent primitives. This directory contains
authored source files, reference knowledge, and build configuration for
AI-native development. It is not coupled to any forge (GitHub, GitLab, etc.).

## Directory Structure

| Directory | Committed | Purpose |
|-----------|-----------|---------|
| `prompts/` | Yes | Authored TOML/YAML prompt sources — compiled to Markdown by promptyst |
| `context/` | Yes | Reference knowledge loaded on demand by agents |
| `instructions/` | Yes | Persistent rules scoped by file pattern |
| `memory/` | Yes | Design decisions persisting across sessions |
| `agents/` | Yes | Agent persona definitions |
| `specs/` | Yes | Implementation-ready blueprints |
| `skills/` | Yes | Packaged capabilities for reuse and auto-discovery |
| `context/references/deps/` | No | Generated dependency digests (Context7/repomix) |
| `output/` | No | Rendered Markdown from prompt sources |

## Build Pipeline

```
.ai/prompts/*.{toml,yaml}                         authored source
.ai/context/primitive-composability-schema.yaml    composability rules
        |
        | nix run .#write-context-docs
        v
.ai/AGENTS.md                                     this file (hybrid)
.ai/output/*.md                                   rendered aspect docs
AGENTS.md                                         root scope (project-wide)
```

Rebuild after changing prompts or schema:

```bash
nix run .#write-context-docs
```

## Authoring

- **New prompt**: Drop a `.toml` or `.yaml` file in `prompts/` following the
  promptyst schema (aspect, context, constraints, steps, inputs, schema, checkpoints).
- **New context**: Add `<topic>.context.md` to `context/`.
- **New instruction**: Add `<domain>.instructions.md` to `instructions/` with
  `applyTo:` frontmatter.
- **Record a decision**: Append to `memory/decisions.memory.md`.

## Composability Rules

<!-- BEGIN GENERATED SECTION -->

# Agent Primitives

Composability rules for PROSE agent primitives.
Source: `.ai/context/primitive-composability-schema.yaml`

## Tiers

| Tier | Members | Can | Cannot |
| --- | --- | --- | --- |
| active | agent, prompt | invoke, reference, produce, auto-load | — |
| passive | instruction, context, memory, spec | reference | invoke, produce |
| meta | skill, agents_md | reference, auto-load | invoke |

**active**: Active primitives orchestrate execution. Agents are the top-level personas; prompts are the workflow layer invoked by users. Both can reference passive primitives and write back to memory.

**passive**: Passive primitives are consumed by active primitives. The only exception is instruction → agents_md (via apm compile), which is a build-time transformation, not a runtime invocation.

**meta**: Meta primitives package or compile other primitives. Skills are auto-discovered by agents. AGENTS.md is inherited via directory tree walk.

## Primitives

| Primitive | File pattern | Tier | Description |
| --- | --- | --- | --- |
| agent | `*.agent.md` | active | Role-based persona with bounded tool access and optional handoffs. The top-level orchestrator in the composition hierarchy. |
| instruction | `*.instructions.md` | passive | Persistent rules scoped by file glob. Automatically injected into agents when working on matching files. Never invokes anything. |
| prompt | `*.prompt.md` | active | Reusable phased workflow invoked on demand. The primary orchestrator of execution — activates agents, references knowledge, produces output. |
| context | `*.context.md` | passive | Reference knowledge loaded on demand via markdown links. Pure data — no outbound edges except to other context files. |
| memory | `*.memory.md` | passive | Decision log persisting across sessions. Written to by active primitives after execution. Read on demand. Never invokes anything. |
| spec | `*.spec.md` | passive | Implementation-ready blueprint. Consumed by prompts as input, produced by specification workflows as output. Never invokes anything. |
| skill | `SKILL.md` | meta | Packaged capability for distribution and auto-discovery. Contains references, scripts, and assets. Agents auto-summon skills based on description match to current task. |
| agents_md | `AGENTS.md` | meta | Compiled portable context. Produced by apm compile from instructions, context, and memory. Inherited by agents via directory tree walk. |

### Frontmatter

**agent**: required(`description`) optional(`tools`, `handoffs`, `model`)

**instruction**: required(`applyTo`) optional(`description`)

**prompt**: required(`description`) optional(`mode`, `agent`, `model`, `tools`, `mcp`, `input`)

**context**: optional(`description`)

**spec**: optional(`description`)

**skill**: required(`name`, `description`) optional(`license`, `allowed-tools`, `metadata`)

## Valid Edges

| From | To | Verb | Mechanism | Direction |
| --- | --- | --- | --- | --- |
| agent | agent (other) | hands-off-to | handoffs: frontmatter field | invoke |
| agent | agent (other) | spawns | agent/runSubagent tool | invoke |
| agent | instruction | auto-loads | applyTo glob match on active files | auto-load |
| agent | context | references | markdown links in body | reference |
| agent | memory | reads | markdown links in body | reference |
| agent | memory | updates | writes decisions after significant outcomes | produce |
| agent | skill | auto-discovers | description match to current task | auto-load |
| agent | agents_md | inherits | directory tree walk, closest file wins | auto-load |
| prompt | agent | activates | mode: or agent: frontmatter field | invoke |
| prompt | context | references | markdown links in body | reference |
| prompt | memory | reads | markdown links in body | reference |
| prompt | memory | updates | learning integration phase output | produce |
| prompt | spec | consumes | markdown links or ${specFile} parameter | reference |
| prompt | spec | produces | specification workflow output | produce |
| prompt | instruction | references | markdown links in body | reference |
| prompt | instruction | updates | discovery-driven enhancement | produce |
| prompt | prompt | chains-to | sequential invocation (human-mediated) | invoke |
| instruction | context | references | markdown links in body | reference |
| instruction | memory | references | markdown links in body | reference |
| instruction | agents_md | compiles-into | apm compile merges by applyTo group | produce |
| context | context | references | markdown cross-links | reference |
| skill | context | references | links to references/ subdirectory | reference |
| agents_md | agent | inherited-by | runtime directory tree walk | auto-load |

## Composability Matrix

```
            TO →
FROM ↓      agent     instr     prompt    context   memory    spec      skill     agents.md 
────────────────────────────────────────────────────────────────────────────────────────────
agent       H,S       AL        ·        R         R,P       ·        AL        AL        
instr       ·        ·        ·        R         R         ·        ·        P         
prompt      I         R,P       C         R         R,P       R,P       ·        ·        
context     ·        ·        ·        R         ·        ·        ·        ·        
memory      ·        ·        ·        ·        ·        ·        ·        ·        
spec        ·        ·        ·        ·        ·        ·        ·        ·        
skill       ·        ·        ·        R         ·        ·        ·        ·        
agents.md   AL        ·        ·        ·        ·        ·        ·        ·        
```

**I**=invokes **H**=hands-off **S**=spawns **AL**=auto-loads **R**=references **P**=produces **C**=chains-to **·**=invalid

## Invalid Edges

- **instruction** cannot invoke **agent, prompt, skill**: Instructions are passive rules. They are injected into agents via applyTo, they never invoke or execute anything.
- **context** cannot invoke **agent, prompt, instruction, memory, spec, skill**: Context is pure reference knowledge. No outbound edges except cross-references to other context files.
- **memory** cannot invoke **agent, prompt, instruction, context, spec, skill**: Memory is pure state. It is written to and read from, but never initiates any action.
- **spec** cannot invoke **agent, prompt, instruction, skill**: Specs are blueprints consumed by prompts. They cannot invoke agents or trigger execution.
- **skill** cannot invoke **prompt, instruction**: Skills describe capabilities for auto-discovery. They do not directly execute prompts or load instructions. Agents mediate.
- **agent** cannot consumes **spec**: Agents do not directly consume specs. Prompts mediate the spec-to-agent path.
- **prompt** cannot hands-off-to **agent**: Only agents can declare handoffs. Prompts activate agents via mode/agent frontmatter, but cannot hand off between them.

## Feedback Loops

**learning** (`prompt → memory → prompt`): Prompts update memory after execution. Future prompts read memory to avoid repeating mistakes. Human-mediated cycle — the same prompt instance doesn't read its own writes.

**delegation** (`agent → agent → agent`): Agents hand off to other agents via handoffs frontmatter or spawn subagents via tools. Enables specialization without monolithic personas.


<!-- END GENERATED SECTION -->
