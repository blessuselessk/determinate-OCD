# Design Decisions

## 2026-03-01: Platform-agnostic agent primitives

**Decision:** Use `.ai/` as the canonical home for PROSE agent primitives instead of `.github/`.
**Rationale:** `.github/` is forge-specific. `.ai/` works on any platform and keeps agent infrastructure separate from CI/CD.
**Trade-off:** Breaks compatibility with tools that expect `.github/prompts/`, `.github/instructions/`, etc. Projection layer (symlinks or hooks) can bridge if needed.

## 2026-03-01: Hybrid AGENTS.md generation

**Decision:** `.ai/AGENTS.md` is a hybrid — hand-authored header (`AGENTS.md.header`) with generated composability section from the schema YAML.
**Rationale:** The directory guide and build pipeline docs change infrequently and benefit from human authoring. The composability rules are derived from a structured schema and should stay in sync automatically.
**Trade-off:** Two sources to maintain (header + schema), but the build pipeline assembles them deterministically.

## 2026-03-01: YAML prompt support

**Decision:** Added `from-yaml` to promptyst alongside `from-toml`. Both use shared `_from-data` helper.
**Rationale:** YAML is more readable for complex prompt descriptions. Typst has built-in `yaml()` parser. The mapping logic after parsing is format-agnostic.
**Trade-off:** None significant — one extra function, tested for equivalence with TOML.
