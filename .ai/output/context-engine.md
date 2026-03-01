# Prompt: ocd.context-engine

**Version:** 0.1.0

## Role
Layer 0 context engine — regenerates _context/ artifacts on every NixOS rebuild, exposes context to OpenClaw via well-known paths

## Context: context-engine-ctx
| Key | Value |
| --- | ----- |
| status | INACTIVE — lives under _layer0/ (excluded by /_  infix). Move to modules/community/ocd/context-engine.nix to activate. |
| classes | Two classes: nixos (system-level activation script) and homeManager (user-level context exposure) |
| flakeRoot | /etc/nixos — adjust if flake root differs |
| namespaces | community/ocd (extensible list — add user and infra namespaces as needed) |
| manifest | _context/manifest.json — machine-readable inventory: aspects, classes, generation, timestamp |
| dependency-map | _context/dependency-map.md — markdown table parsed from flake.lock (input, type, source, rev) |
| contextHome | ${config.xdg.dataHome}/ocd-context — stable path for OpenClaw tool discovery |
| env-var | OCD_CONTEXT_HOME session variable set via home.sessionVariables |
| feedback-loop | rebuild → regenerate _context/ → agent reads → agent modifies → rebuild |

## Constraints
1. Must remain under _layer0/ (inactive) until all prerequisites are met: den wiring, namespaces, working rebuild pipeline
2. Activation script must run after 'etc' and 'users' deps so system state is settled
3. All _context/ artifacts must be deterministic: same inputs → same outputs (except change-log.md which is append-only)
4. Context home uses symlinks to actual _context/ dirs — OpenClaw must not need to know flake root path

## Steps
1. Define flakeRoot and namespaces list for context generation scope
2. Create generateManifest script: walk namespace dir, detect aspect classes via grep, produce manifest.json with jq
3. Create generateDependencyMap script: parse flake.lock with jq, produce dependency-map.md table
4. Combine into regenerateContext activation script, wire as system.activationScripts.layer0-context with deps
5. Define homeManager class: set OCD_CONTEXT_HOME env var pointing to xdg.dataHome/ocd-context

## Inputs
| Name | Type | Description |
| ---- | ---- | ----------- |
| flakeRoot | string | Path where the flake is deployed (default: /etc/nixos) |
| namespaces | list(string) | Namespace paths to generate context for (e.g. community/ocd) |

## Output Schema: context-engine-output
| Field | Type | Description |
| ----- | ---- | ----------- |
| manifest.json | file | Machine-readable aspect inventory per namespace |
| dependency-map.md | file | Human/AI-readable flake dependency table |
| OCD_CONTEXT_HOME | env-var | Stable path for OpenClaw context discovery |

## Checkpoint: verify-activation-deps
| Property | Value |
| -------- | ----- |
| after-step | 4 |
| assertion | Activation script declares deps on 'etc' and 'users' |
| on-fail | halt |

## Checkpoint: verify-context-home
| Property | Value |
| -------- | ----- |
| after-step | 5 |
| assertion | OCD_CONTEXT_HOME is set in home.sessionVariables |
| on-fail | halt |