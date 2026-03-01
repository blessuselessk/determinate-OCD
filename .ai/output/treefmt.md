# Prompt: infra.treefmt

**Version:** 0.1.0

## Role
Source tree formatting — nixfmt, deadnix, mdformat, yamlfmt, taplo, prettier with exclusions for generated files

## Context: treefmt-ctx
| Key | Value |
| --- | ----- |
| input | treefmt-nix (github:numtide/treefmt-nix), inputs.nixpkgs.follows = nixpkgs |
| root-marker | projectRootFile = flake.nix |
| formatters | nixfmt, deadnix, mdformat, yamlfmt, taplo, prettier (JSON only) |
| exclusions | mdformat excludes .ai/output/*, .ai/AGENTS.md, rendered PROSE (.ai/agents/*.md, .ai/instructions/*.md, .ai/workflows/*.md, .ai/skills/*/SKILL.md), per-primitive AGENTS.md files, .ai/context/references/deps/*.md, .github/**/*.md |
| on-unmatched | info (via lib.mkDefault — warns but does not fail) |
| scope | perSystem module — applies to all systems |

## Constraints
1. Generated .ai/ output files must be excluded from mdformat to preserve promptyst rendering
2. treefmt-nix input must follow nixpkgs to avoid duplicate nixpkgs evaluations
3. on-unmatched must stay info (not error) to tolerate unformatted file types

## Steps
1. Import treefmt-nix.flakeModule and declare the flake input with nixpkgs follows
2. Enable formatters: nixfmt, deadnix, mdformat, yamlfmt, taplo, prettier
3. Add mdformat exclusion patterns for all generated Markdown paths
4. Set projectRootFile to flake.nix and on-unmatched to info

## Inputs
| Name | Type | Description |
| ---- | ---- | ----------- |
| treefmt-nix-url | string | Override URL for treefmt-nix input (default: github:numtide/treefmt-nix) |

## Output Schema: treefmt-output
| Field | Type | Description |
| ----- | ---- | ----------- |
| formatted | bool | Whether all source files pass formatting checks |
| excluded-paths | list(string) | Paths excluded from mdformat |

## Checkpoint: verify-exclusions
| Property | Value |
| -------- | ----- |
| after-step | 3 |
| assertion | All .ai/output/*.md and rendered PROSE files are excluded from mdformat |
| on-fail | halt |