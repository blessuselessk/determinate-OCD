# Primitive Composability Chart

Source schema: [primitive-composability-schema.yaml](primitive-composability-schema.yaml)
See also: [matrix](primitive-composability-matrix.md)

## Directed Graph

Layered top-down: meta → active → passive. Flow follows gravity
except for two feedback loops (double arrows back upward).

```mermaid
graph TB
    subgraph Meta ["Meta (packages / compiles)"]
        SKILL[skill]
        AGENTSMD[AGENTS.md]
    end

    subgraph Active ["Active (orchestrates)"]
        AGENT_A[agent A]
        AGENT_B[agent B]
        PROMPT[prompt]
    end

    subgraph Passive ["Passive (consumed)"]
        INSTR[instruction]
        CONTEXT[context]
        MEMORY[memory]
        SPEC[spec]
    end

    %% meta → active (implicit loading)
    AGENTSMD -.->|inherited-by| AGENT_A
    AGENTSMD -.->|inherited-by| AGENT_B
    SKILL -.->|auto-discovered-by| AGENT_A

    %% active ↔ active
    AGENT_A -->|hands-off-to| AGENT_B
    AGENT_A -->|spawns| AGENT_B
    PROMPT -->|activates| AGENT_A
    PROMPT -->|chains-to| PROMPT

    %% active → passive (references / reads)
    AGENT_A -.->|auto-loads| INSTR
    AGENT_A -->|references| CONTEXT
    AGENT_A -->|reads| MEMORY
    PROMPT -->|references| CONTEXT
    PROMPT -->|reads| MEMORY
    PROMPT -->|consumes| SPEC
    PROMPT -->|references| INSTR

    %% passive → passive (cross-references)
    INSTR -->|references| CONTEXT
    INSTR -->|references| MEMORY
    CONTEXT -->|references| CONTEXT
    SKILL -->|references| CONTEXT

    %% feedback loops (upward / write-back)
    PROMPT ==>|updates| MEMORY
    PROMPT ==>|produces| SPEC
    PROMPT ==>|updates| INSTR
    AGENT_A ==>|updates| MEMORY

    %% passive → meta (build-time compilation)
    INSTR ==>|compiles-into| AGENTSMD
```

## Legend

| Arrow | Meaning | Direction |
|-------|---------|-----------|
| `→` solid | Explicit reference or invocation | downward (with gravity) |
| `==>` double | Produce / write-back | upward (against gravity — feedback) |
| `-.->` dotted | Auto-load / auto-discover | implicit, pattern-triggered |

## Clarifications

**Agent → Agent** is not self-referential. Two distinct mechanisms:

- **Handoff**: Agent A completes its phase, passes context to Agent B
  (e.g., researcher → writer). Sequential, one active at a time.
- **Spawn**: Agent A creates a scoped subagent for a subtask,
  receives the result. Parent-child, concurrent.

**Prompt → Spec** has two distinct edges:

- **Consumes** (→): reads an existing spec as input to implementation.
- **Produces** (==>): a specification workflow creates a new spec file.

**Instruction → AGENTS.md → Agent** is a two-phase path:

- **Build-time**: `apm compile` merges instructions into AGENTS.md.
- **Runtime**: agents walk the directory tree and inherit the nearest AGENTS.md.

## Feedback Loops

The only two cycles in the graph:

1. **Learning**: prompt → memory → prompt
   Execution records decisions; future runs read them. Human-mediated —
   the same prompt instance does not read its own writes.

1. **Delegation**: agent A → agent B → agent C
   Handoffs and subagent spawning. Enables specialization without
   monolithic personas.

Everything else is strictly top-down: meta → active → passive.
