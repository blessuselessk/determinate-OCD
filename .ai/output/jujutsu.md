# Prompt: lessuseless.jujutsu

**Version:** 0.1.0

## Role
Personal Jujutsu VCS config — aliases, revsets, difftastic, SSH signing, tool wrapping (jjui, lazyjj, jj-fzf)

## Context: jujutsu-ctx
| Key | Value |
| --- | ----- |
| input | jjui (github:idursun/jjui) — TUI for jj, declared via flake-file.inputs |
| packages | lazyjj, jj-fzf (from nixpkgs), jjui-wrapped (with ssh-add pre-check) |
| diff-tool | difftastic with --color=always for diff and show commands |
| signing | SSH backend, behaviour=own, key=~/.ssh/id_ed25519.pub |
| editor | nvim (editor), meld-3 (diff-editor), meld (merge-editor) |
| revset-aliases | trunk()=main@origin, compared_to_trunk(), immutable_heads(), closest_bookmark(to), default_log(), default(), recent() (1 week) |
| aliases | s=show, l=log compared_to_trunk, ll=log .., lr=log default()&recent(), sq=squash -i, su/sd/sU/sD=directional squash, tug=advance bookmark |
| default-command | log --no-pager --reversed --stat --template builtin_log_compact_full_description --limit 3 |
| push-bookmark-template | lessuseless/jj-change- |
| jjui-config | ~/.config/jjui/config.toml — leader.e sends 'jj edit $change_id && $VISUAL $file' |
| scope | lessuseless namespace, homeManager class only |

## Constraints
1. jjui must be wrapped with ssh-add pre-check to avoid silent auth failures
2. Signing key path and user.name/email are TODOs — must be set before real use
3. conflict-marker-style must be git for compatibility with standard merge tools
4. movement.edit must be false to prevent accidental working-copy edits on navigation

## Steps
1. Declare jjui flake input and build jjui-wrapped with ssh-add pre-check
2. Add lazyjj, jj-fzf, and jjui-wrapped to home.packages
3. Enable programs.jujutsu with difftastic diff-formatter
4. Define revset-aliases: trunk, compared_to_trunk, immutable_heads, closest_bookmark, default, recent
5. Define template-aliases for short IDs and timestamps
6. Configure UI: default-command, editors, conflict-marker-style, movement.edit=false
7. Set up SSH signing with behaviour=own
8. Define command aliases (s, l, ll, lr, sq, su, sd, sU, sD, tug)
9. Generate jjui config.toml with leader.e edit-file binding

## Inputs
| Name | Type | Description |
| ---- | ---- | ----------- |
| jjui-url | flake-input | GitHub source for jjui TUI (default: github:idursun/jjui) |
| signing-key | path | SSH public key path for commit signing |

## Output Schema: jujutsu-output
| Field | Type | Description |
| ----- | ---- | ----------- |
| programs-enabled | bool | Whether programs.jujutsu is enabled in Home Manager |
| packages-installed | list(string) | jjui-wrapped, lazyjj, jj-fzf available in home.packages |
| aliases-defined | list(string) | All jj aliases registered in settings.aliases |

## Checkpoint: verify-ssh-wrap
| Property | Value |
| -------- | ----- |
| after-step | 1 |
| assertion | jjui-wrapped script calls ssh-add -l before launching jjui |
| on-fail | halt |

## Checkpoint: verify-revsets
| Property | Value |
| -------- | ----- |
| after-step | 4 |
| assertion | trunk() resolves to main@origin and compared_to_trunk() references trunk() |
| on-fail | halt |