# jj‑workspace Hooks – Framework‑Agnostic Guide

These hooks replace the default `git worktree` behaviour with **jj workspaces** so that multiple tools (e.g., IDEs, CI pipelines, or custom scripts) share a single repository store. This ensures that changes made in one environment are immediately visible in all others.

---

## Why Use jj Workspaces?

- **Shared repository store** – Unlike `git worktree`, each worktree gets its own copy of the hidden `.jj/` directory, preventing cross‑tool visibility.
- **Instant visibility** – Changes made via one tool (e.g., a code editor) are instantly reflected in any other tool that uses the same jj workspace.
- **Lightweight** – No extra disk space for duplicate `.jj/` metadata.

---

## Prerequisites

- **jj** – The version‑control tool that provides workspaces.
- **jq** – Command‑line JSON processor (used to merge hook configuration).

Install them if you haven't already:
```sh
# macOS (Homebrew)
brew install jj jq
```

---

## Installation – Step‑by‑Step

1. **Clone the repository** (if you haven't already) and navigate to its root:
   ```sh
   git clone <repo‑url>
   cd determinable-OCD
   ```
2. **Locate the hook scripts** – They live in `modules/lair/plugins/hooks`:
   ```sh
   ls modules/lair/plugins/hooks
   # → jj-worktree-create.sh  jj-worktree-remove.sh
   ```
3. **Add the hooks to your tool's configuration**
   - Most tools accept a JSON configuration file (e.g., `settings.json`).
   - The following command merges the required hook entries into an existing configuration file (`~/.mytool/settings.json`).
   ```sh
   jq -s '.[0] * .[1]' \
     ~/.mytool/settings.json \
     <(jq -n \
       --arg create "$(pwd)/modules/lair/plugins/hooks/jj-worktree-create.sh" \
       --arg remove "$(pwd)/modules/lair/plugins/hooks/jj-worktree-remove.sh" \
       '{hooks: {WorktreeCreate: [{hooks: [{type: "command", command: $create, timeout: 30}]}], WorktreeRemove: [{hooks: [{type: "command", command: $remove, timeout: 30}]}]}}') \
     > /tmp/merged-settings.json && mv /tmp/merged-settings.json ~/.mytool/settings.json
   ```
   > **Note:** Replace `~/.mytool/settings.json` with the actual path to your tool's configuration file.
4. **Restart the tool** – After the merge, restart your IDE/editor or any service that reads the configuration so the hooks become active.

---

## Uninstalling the Hooks

To remove the hooks, edit your configuration file and delete the `WorktreeCreate` and `WorktreeRemove` entries under the `hooks` section, then restart the tool.

---

## What the Hooks Do

- **`jj-worktree-create.sh`** – Invoked when a new worktree is requested; it creates a corresponding jj workspace instead.
- **`jj-worktree-remove.sh`** – Invoked when a worktree is removed; it cleans up the associated jj workspace.

These scripts are deliberately simple and can be adapted to any environment that supports executing shell commands on worktree events.

---

## Customisation

If your tool uses a different JSON schema for hooks, adjust the `jq` merge command accordingly. The core idea remains the same: merge a `hooks` object that maps `WorktreeCreate` and `WorktreeRemove` to the two shell scripts provided.

---

*Happy hacking with jj workspaces!*
