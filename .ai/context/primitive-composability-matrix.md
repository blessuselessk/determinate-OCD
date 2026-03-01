# Primitive Composability Matrix

Source schema: [primitive-composability-schema.yaml](primitive-composability-schema.yaml)
See also: [chart (mermaid)](primitive-composability-chart.md)

```
              TO →
FROM ↓     agent  instr  prompt  context  memory  spec  skill  agents.md
─────────────────────────────────────────────────────────────────────────
agent        H,S    AL      ·       R      R,P     ·     AL      AL
instr         ·      ·      ·       R       R      ·      ·       P
prompt        I      R,P    C       R      R,P    R,P     ·       ·
context       ·      ·      ·       R       ·      ·      ·       ·
memory        ·      ·      ·       ·       ·      ·      ·       ·
spec          ·      ·      ·       ·       ·      ·      ·       ·
skill         ·      ·      ·       R       ·      ·      ·       ·
agents.md    AL      ·      ·       ·       ·      ·      ·       ·
```

## Key

| Code | Verb | Direction |
|------|------|-----------|
| **I** | invokes | active execution |
| **H** | hands-off-to | lateral delegation (agent A → agent B, sequential) |
| **S** | spawns | subagent creation (agent A → child agent, concurrent) |
| **AL** | auto-loads | implicit, pattern-triggered |
| **R** | references | explicit, markdown links |
| **P** | produces / updates | write-back — creates new or updates existing (feedback) |
| **C** | chains-to | sequential invocation (human-mediated) |
| **·** | invalid | no valid edge exists |

## Reading the Matrix

- **Rows** = what a primitive can do (outbound edges)
- **Columns** = what can be done to a primitive (inbound edges)
- **Dense rows** (agent, prompt) = active orchestrators
- **Empty rows** (memory, spec) = pure sinks, only written to or consumed
- **Multiple codes** in a cell (e.g. R,P) = both reference and produce edges exist

## Tier Summary

| Tier | Members | Row density |
|------|---------|-------------|
| Active | agent, prompt | 5-7 non-empty cells |
| Passive | instruction, context, memory, spec | 0-2 non-empty cells |
| Meta | skill, agents.md | 1 non-empty cell |
