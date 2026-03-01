---
applyTo: ".ai/**/*.md"
description: "PROSE primitive authoring rules for the .ai/ directory"
---

## File Naming

| Primitive | Pattern | Example |
|-----------|---------|---------|
| Agent | `*.agent.md` | `nix-aspect-author.agent.md` |
| Prompt | `*.prompt.md` | `new-aspect.prompt.md` |
| Instruction | `*.instructions.md` | `dendritic.instructions.md` |
| Context | `*.context.md` | `stack.context.md` |
| Memory | `*.memory.md` | `decisions.memory.md` |
| Spec | `*.spec.md` | `ai-directory-migration.spec.md` |
| Skill | `SKILL.md` (in named subdirectory) | `primitive-composability/SKILL.md` |

## Required Frontmatter

All primitives use YAML frontmatter (`---` delimited).

| Primitive | Required | Optional |
|-----------|----------|----------|
| Agent | `description` | `tools`, `handoffs`, `model` |
| Prompt | `description` | `mode`, `agent`, `model`, `tools`, `mcp`, `input` |
| Instruction | `applyTo` (glob) | `description` |
| Context | — | `description` |
| Memory | — | — |
| Spec | — | `description` |
| Skill | `name`, `description` | `license`, `allowed-tools`, `metadata` |

## Tier Rules

- **Active** (agent, prompt): Can invoke other primitives, reference passive ones, produce outputs
- **Passive** (instruction, context, memory, spec): Can only reference — never invoke or produce
- **Meta** (skill, agents_md): Auto-loaded by discovery, cannot invoke

## Prohibited

- Passive primitives must not contain invocation verbs (`activates`, `hands-off-to`, `spawns`)
- Agents cannot consume specs directly — prompts mediate
- Prompts cannot hand off to agents — they activate
- Do not edit generated `AGENTS.md` files — they are rebuilt by the pipeline

## Cross-References

Use relative paths from the file's directory:
```markdown
[Stack reference](../context/stack.context.md)
[Composability schema](../context/primitive-composability-schema.yaml)
```

## References

- [Composability schema](../context/primitive-composability-schema.yaml)
- [Composability skill](../skills/primitive-composability/SKILL.md)
