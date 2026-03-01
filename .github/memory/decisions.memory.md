# Architectural Decisions

## 2026-02-28: PROSE primitive structure

**Decision:** Decompose monolithic CLAUDE.md into PROSE primitives
**Rationale:** 800-line CLAUDE.md violated Progressive Disclosure (loaded everything into every session), Orchestrated Composition (one mega-document), and Reduced Scope (no phase decomposition)
**Result:** AGENTS.md (principles), .instructions.md (scoped rules), .context.md (on-demand reference), slim CLAUDE.md (links to primitives)

## 2026-02-28: CI as build loop

**Decision:** Use GitHub Actions for NixOS build validation, not local nixos-rebuild
**Rationale:** Development happens on macOS with OrbStack. Cannot run nixos-rebuild locally. GHA with DeterminateSystems/nix-installer-action provides nix flake check + nix build on every push.

## 2026-02-28: Minimal flake first, no spec-kit

**Decision:** Bootstrap a minimal working flake before adding context-engine pipeline, OpenClaw, or Promptyst integration
**Rationale:** Spec-kit adds ceremony to a project that already has extensive design documentation. The design exists — what's missing is a single evaluating .nix file. Layer on complexity incrementally from a working base.

## 2026-02-28: \_context/agents/ abandoned

**Decision:** Agent operational boundaries belong in Nix aspects, not parallel markdown files
**Rationale:** Nothing loaded `_context/agents/claude-code.md` or `openclaw.md`. Claude Code auto-loads CLAUDE.md from ancestor chain — separate agent files have no loading mechanism. OpenClaw policy is configuration, which the dendritic pattern already handles as aspects.

## 2026-02-28: Three content categories

**Decision:** CLAUDE.md files contain three types of content that need different treatment
**Categories:**

- Policy/intent (human-authored, e.g. "OpenClaw may NOT modify networking.nix")
- Structural facts (generated from code, e.g. aspect inventories in \_context/manifest.json)
- Conventions/patterns (partially authored templates + generated examples)
