# OpenClaw — Troubleshooting & Configuration Guide

## Golden Paths

OpenClaw has three deployment topologies. Identify which one you're working with before doing anything else — they have different diagnostic workflows.

| GP | Topology | Gateway runs on | Node/client runs on | Diagnostic scope |
|----|----------|----------------|---------------------|------------------|
| GP1 | Single Mac | macOS (launchd) | Same machine | Local only |
| GP2 | VPS Gateway + Mac Node | Linux VPS (systemd) | macOS app over Tailscale | **Both hosts** — gateway CLI on VPS + local CLI and Mac app |
| GP3 | Laptop-only dev | macOS/Linux laptop | Optional | Local only |

This flake uses **GP2**: gateway on fogell (Linux), node on mclovin (macOS), connected via Tailscale.

## Troubleshooting workflow

### 1. Gather diagnostics from ALL hosts in scope

For GP2, you must check **both** sides before forming a theory:

**On the Mac (node):**

```bash
openclaw status --all
openclaw doctor
openclaw security audit --deep
```

**On the gateway host (fogell):**

```bash
ssh root@fogell.serval-minor.ts.net
openclaw status --all
openclaw security audit --deep
journalctl -u openclaw-gateway --no-pager -n 50
```

**In the Mac app:**
Check the Debug tab — it shows the live connection state, SSH tunnel status, and error messages that the CLI may not surface.

Follow every suggested next action the CLI outputs. Chain them until you run out of leads.

### 2. Build a model from the diagnostics

Only after collecting complete output from all hosts should you look at the Nix configuration. The CLI's diagnostic output is ground truth — not inferences from reading `.nix` files.

Key questions to answer:

- What mode is each side in? (local / remote)
- What transport is in use? (direct / SSH tunnel / Tailscale Serve)
- What auth layer is failing? (token / device signature / TLS / connectivity)
- Does the config JSON on disk match what you expect from the Nix aspects?

### 3. Resolve ambiguity before acting

If the diagnostics or docs leave anything unclear — URL schemes (`wss://` vs `https://`), auth modes, transport options, config field semantics:

1. Read the upstream nix-openclaw docs (`docs/golden-paths.md`, README, generated config schema)
1. Ask the user targeted questions
1. Think more

Do not guess and ship. Do not infer config field semantics from names alone — verify from the schema or docs.

### 4. Safety rules

- **Never delete user state files** (backups, config, pairing state, `.before-nix-darwin` files) without explicit permission.
- **Never force-overwrite** openclaw config or state directories.
- When Home Manager backup conflicts occur, explain the situation and let the user decide.

## Secrets (agenix) lifecycle

Secrets flow through four stages. Understanding this sequence prevents common mistakes like putting plaintext in the nix store or wondering why a host can't decrypt.

### 1. Recipients — `secrets.nix` (repo root)

`secrets.nix` maps each `.age` file to a list of **recipient public keys** — the SSH keys authorized to decrypt it. Recipients are typically:

- **User keys** — so the developer can edit/rekey secrets with `ragenix`
- **Host keys** — so the target machine can decrypt at activation time

```nix
let
  lessuseless = "ssh-ed25519 AAAA...";  # user — can edit secrets
  fogell = "ssh-ed25519 AAAA...";       # host — can decrypt at activation
in {
  "modules/lessuseless/secrets/openclaw-gateway-token.age".publicKeys = [ lessuseless fogell ];
}
```

**If a host key is missing, that host cannot decrypt the secret.** This is the most common cause of "secret not available" on a machine.

### 2. Encrypt/edit — `ragenix` (dev machine)

```bash
ragenix -e modules/lessuseless/secrets/foo.age
# or if not in PATH:
nix run nixpkgs#ragenix -- -e modules/lessuseless/secrets/foo.age
```

This encrypts/re-encrypts the file to all recipients listed in `secrets.nix`. The `.age` file is safe to commit — it's ciphertext. After changing recipients in `secrets.nix`, rekey all secrets:

```bash
ragenix -r  # or: nix run nixpkgs#ragenix -- -r
```

### 3. Nix eval & build — paths only, never plaintext

During eval, `age.secrets.<name>.file = ./secrets/foo.age` records the encrypted file path. The encrypted `.age` file is copied to the nix store. **The secret is never decrypted during build** — only the path and metadata (owner, mode) are wired into the activation script.

`config.age.secrets.<name>.path` resolves to the **runtime** path (e.g., `/run/agenix/foo`) where the secret will appear after activation. Use this in service configs:

```nix
# fogell.nix — reference the runtime path, not the .age file
ExecStart = "... $(cat ${config.age.secrets.openclaw-gateway-token.path}) ...";
```

### 4. Activation & runtime — host decrypts

On system activation (`nixos-rebuild switch` / `darwin-rebuild switch`):

- **NixOS**: agenix systemd service decrypts `.age` files using the host's SSH key → plaintext appears at `/run/agenix/<name>`
- **macOS**: agenix darwin module does the same, but the host key must be a recipient in `secrets.nix`

Services then read from the runtime path. The plaintext only exists in memory/tmpfs, never in the nix store.

### GP2 secret flow

| Secret | Encrypted to | Decrypted on | Consumed by |
|--------|-------------|--------------|-------------|
| `openclaw-gateway-token` | lessuseless + fogell | fogell (`/run/agenix/...`) | Gateway service via `OPENCLAW_GATEWAY_TOKEN` env var |
| `telegram-bot-token` | lessuseless + fogell | fogell | Gateway telegram channel config |

**macOS gap**: mclovin has `ocd.agenix` and `lessuseless.secrets` in its includes, so the agenix darwin module is loaded and `age.secrets.openclaw-gateway-token` is declared. However, **mclovin's host SSH key is not a recipient** in `secrets.nix` — so agenix activates but fails silently because it cannot decrypt. The gateway token on the Mac is currently provided via `~/.openclaw/.env` (manual). To fix properly: add mclovin's host SSH public key to `secrets.nix` and rekey with `ragenix -r` (or `nix run nixpkgs#ragenix -- -r`).

### Common mistakes

- **Putting plaintext tokens in `.nix` files** — they end up world-readable in the nix store. Use `config.age.secrets.<name>.path` or SecretRefs instead.
- **Missing host key in `secrets.nix`** — the host can't decrypt. Add the key and `ragenix -r`.
- **Referencing the `.age` file at runtime** — that's the encrypted blob. Use `config.age.secrets.<name>.path` for the decrypted runtime path.
- **Assuming env vars are available everywhere** — `launchctl setenv` sets vars in the GUI/launchd domain. Terminal shells need separate wiring (shell profile, `~/.openclaw/.env`, or direnv).

## Key references

- **Upstream source**: Pinned in `flake.lock` under `nix-openclaw`. Resolve the store path:
  ```bash
  nix eval --raw --impure --expr '(builtins.getFlake "github:arubis/nix-openclaw/<rev>").outPath'
  ```
- **Config schema**: `<store-path>/nix/generated/openclaw-config-options.nix`
- **Golden paths doc**: `<store-path>/docs/golden-paths.md`
- **Gateway module**: `<store-path>/nix/modules/nixos/openclaw-gateway.nix`
- **HM module**: `<store-path>/nix/modules/home-manager/openclaw/`

## Refactoring status

This configuration is mid-refactor:

1. **Upstream build is broken** — `nix-openclaw` (`github:arubis/nix-openclaw`) won't build due to a missing dependency. We're using a pinned branch (`fix/rolldown-sandbox-shim`) as a workaround.
1. **Dendritic community layer** — These aspects follow dendrix conventions (`ocd.<name>.<class>`). The goal is a reusable community layer, not a fork.
1. **Future upstream target** — Once the local configuration is working end-to-end, evaluate whether `gh:openclaw/openclaw` can be used directly as the flake input instead of `nix-openclaw`. Only keep `nix-openclaw` if it provides NixOS/HM module wiring or packaging that the main repo does not.

## Aspects in this directory

| Aspect | Role | Hosts |
|--------|------|-------|
| `openclaw.nix` | GP2 client — HM module with remote gateway config | mclovin |
| `openclaw-gateway.nix` | GP2 gateway — systemd service with hardened security | fogell |

## Known issues & workarounds

| Issue | Cause | Fix |
|-------|-------|-----|
| `appDefaults.nixMode` missing on eval | Upstream `defaultInstance` in HM module doesn't include `nixMode` | Use `instances.default` instead of `programs.openclaw.enable = true` |
| Plugin binary collision (`goplaces`) | Batteries-included package bundles plugin CLIs; HM plugin system also installs them | Set `exposePluginPackages = false` |
| `device signature invalid` through SSH tunnel | SSH tunnel bypasses Tailscale Serve, stripping device identity | `dangerouslyDisableDeviceAuth = true` on gateway (token auth still active) |
| `ECONNREFUSED` on remote gateway | Client URL had `:18789` but Tailscale Serve listens on port 443 (default HTTPS) | Use `wss://fogell.serval-minor.ts.net` (no port) |
| Tailscale ACL blocks port 443 | `tag:desktop` → `tag:server` grants didn't include port 443 | Add `{ src: ["tag:desktop"], dst: ["tag:server"], ip: ["443"] }` grant |
| `gateway token missing` from CLI | `OPENCLAW_GATEWAY_TOKEN` env var not in shell; agenix can't decrypt on Mac (mclovin not a recipient) | Token in `~/.openclaw/.env`; long-term fix: add mclovin's host key to `secrets.nix` and rekey |
| HM clobber conflict on `openclaw.json` | nix-openclaw HM module creates symlinks via `openclawConfigFiles` activation, but HM's `checkLinkTargets` doesn't recognize them as HM-managed | Remove the symlink before rebuild; needs permanent upstream fix or `force = true` |
| `https://` URL rejected as insecure | OpenClaw converts `https://` to `ws://` (not `wss://`) for WebSocket; `ws://` rejected for non-loopback | Always use `wss://` scheme for remote gateway URLs |

______________________________________________________________________

**Maintenance note:** Update this file each time an OpenClaw configuration issue is successfully resolved. Add new entries to "Known issues & workarounds" and refine the troubleshooting workflow. The goal is fewer debugging loops and more targeted fixes over time.
