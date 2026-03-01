---
name: primitive-composability
description: |
  Validate agent primitive compositions against the PROSE tier model.
  Use when creating, modifying, or wiring agent primitives (.agent.md,
  .instructions.md, .prompt.md, .context.md, .memory.md, .spec.md, SKILL.md).
  Enforces valid directed edges between active, passive, and meta tiers.
---

## When This Skill Triggers

You are creating or modifying a file under `.ai/` that is an agent primitive.
Before adding references, invocations, or handoffs between primitives,
validate the composition against the rules below.

## Quick Rules

1. **Check the tier** of your primitive (active / passive / meta)
2. **Passive primitives** (instruction, context, memory, spec) can only reference other primitives — they cannot invoke or produce
3. **Active primitives** (agent, prompt) can invoke, reference, and produce
4. **Agents cannot consume specs directly** — prompts mediate
5. **Only agents can hand off** to other agents — prompts activate, they don't delegate

## Detailed References

For the full edge table, matrix, and invalid edge rules:
- [Composability schema](../../context/primitive-composability-schema.yaml)
- [Composability matrix](../../context/primitive-composability-matrix.md)
- [Composability chart](../../context/primitive-composability-chart.md)
