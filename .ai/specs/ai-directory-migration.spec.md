# Spec: .ai/ Directory Migration

## Problem
Agent primitives are split between `.github/` (PROSE convention) and
`modules/.../_helpers/descriptions/` (co-located with aspects). This
creates confusion about where to author and find primitive files.

## Approach
Consolidate all authored agent primitives under `.ai/`. Keep `.github/`
for GitHub-specific CI/CD only. Update build pipeline references.

## Migration Checklist
- [ ] Move `.github/context/stack.context.md` → `.ai/context/`
- [ ] Move `.github/instructions/dendritic.instructions.md` → `.ai/instructions/`
- [ ] Move `.github/memory/decisions.memory.md` → `.ai/memory/`
- [ ] Move `modules/.../descriptions/*.{toml,yaml}` → `.ai/prompts/`
- [ ] Update `context-compile.nix` descriptions path
- [ ] Update CLAUDE.md references
- [ ] Update `.gitignore` for generated dirs
- [ ] Remove empty `.github/` primitive dirs
- [ ] Verify `nix flake check` passes
