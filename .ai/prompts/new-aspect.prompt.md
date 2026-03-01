______________________________________________________________________

## description: "Create a new dendritic aspect with description and wiring" mode: agent agent: nix-aspect-author

## Phase 1: Gather Requirements

1. Determine the aspect name and namespace (ocd, user, infra)
1. Identify what NixOS options/services it configures
1. List dependencies on other aspects (includes)

**CHECKPOINT**: Confirm aspect name and namespace before proceeding.

## Phase 2: Create Aspect

1. Create `modules/<namespace>/<name>.nix` with the aspect skeleton
1. Wire `includes` for any dependencies
1. Add the aspect to `den.default.includes` if it should be default

## Phase 3: Create Description

1. Create `.ai/prompts/<name>.yaml` with the promptyst schema
1. Run `nix run .#write-context-docs` to verify it renders

## Phase 4: Verify

1. Run `nix flake check`
1. Review the rendered Markdown in `.ai/output/`
