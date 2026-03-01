---
description: "Create and wire an agenix-encrypted secret into a NixOS aspect"
mode: agent
agent: nix-aspect-author
---

## Phase 1: Scope
1. Identify what needs a secret (API key, password, certificate, token)
2. Choose a secret name (kebab-case, descriptive: e.g., `openclaw-telegram-token`)
3. Identify the consuming aspect and user namespace

**CHECKPOINT**: Confirm secret name, consuming aspect, and user namespace before proceeding.

## Phase 2: Encrypt
1. Create the encrypted `.age` file in `modules/<user>/secrets/`
2. Add the secret to `age.secrets.<name>` in the user's secrets aspect
3. Set appropriate `owner`, `group`, and `mode` for the secret

## Phase 3: Wire
1. Reference the secret via `config.age.secrets.<name>.path` in the consuming aspect
2. Add `includes` dependency on the secrets aspect in the consuming aspect
3. Never inline the secret value or hardcode `/run/agenix/` paths

## Phase 4: Verify
1. `jj file track` the new `.age` file and any modified aspects
2. Run `nix flake check` — confirm secret path resolves at eval time
3. Verify the consuming aspect correctly references the secret
