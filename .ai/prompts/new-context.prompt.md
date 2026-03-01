______________________________________________________________________

## description: "Research and author a new .context.md reference file" mode: agent agent: context-author

## Phase 1: Scope

1. Identify the knowledge gap — what dependency, API, or concept needs a reference?
1. Check `.ai/context/` for existing coverage — avoid duplication
1. Name the file: `<topic>.context.md`

**CHECKPOINT**: Confirm the topic and filename before researching.

## Phase 2: Research

1. Read upstream documentation (README, docs site, source code)
1. Read relevant project files that use the dependency
1. Collect key facts: API surface, configuration options, conventions, gotchas

## Phase 3: Author

1. Create `.ai/context/<topic>.context.md` with `description` frontmatter
1. Structure as: purpose statement, reference tables, code examples
1. Optimize for agent consumption — concise, scannable, no narrative filler

## Phase 4: Verify

1. Check cross-references resolve (relative paths to other primitives)
1. Confirm the file follows [primitive authoring rules](../instructions/primitive-authoring.instructions.md)
