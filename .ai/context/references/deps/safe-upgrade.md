# safe-upgrade

> NixOS auto-upgrade with dead man's switch, mechanical health checks, and pluggable confirmation.

Status: **Design spec** — not yet implemented.

## Problem

`ocd.autobots-rebuild` runs `nixos-rebuild switch` every 15 minutes from the `main` branch. If the build succeeds but the new generation breaks a service at runtime (as happened with the openclaw-gateway EACCES crash loop), the broken generation becomes the default boot entry with no automatic recovery. The only fix is to push a corrected commit and wait another 15 minutes — or SSH in manually (if SSH still works).

## Design

Replace `ocd.autobots-rebuild` with `ocd.safe-upgrade`. Two layers with distinct responsibilities:

1. **Mechanical checks** — fast, deterministic, self-contained. If they fail, rollback is immediate. No external dependencies.
2. **Confirmation** — pluggable, optional. An external actor (agent, human, CI) confirms the upgrade is good. The mechanism is variable.

Core principle: **activate first, confirm later, reboot if unconfirmed**.

```
  ┌──────────────┐
  │ Timer fires   │  (every 15 min)
  └──────┬───────┘
         ▼
  ┌──────────────┐
  │ Build         │  nix build
  └──────┬───────┘
         │ succeeds
         ▼
  ┌──────────────────────┐
  │ nixos-rebuild test   │  Activate WITHOUT registering boot entry.
  │                      │  Reboot at any point from here → reverts.
  └──────┬───────────────┘
         │ activation succeeds
         ▼
  ┌──────────────────────┐
  │ Arm dead man's       │  sleep $timeout && shutdown -r now
  │ switch (DMS)         │
  └──────┬───────────────┘
         ▼
  ┌──────────────────────┐
  │ Mechanical checks    │  Autonomous. No external calls.
  │                      │  Services active? Ports open?
  └──────┬───────┬───────┘
       pass    fail → (do nothing, DMS fires → reboot → reverts)
         │
         ▼
  ┌──────────────────────┐
  │ Confirmation         │  Pluggable. Mode depends on config.
  │ (variable mode)      │  See "Confirmation modes" below.
  └──────┬───────┬───────┘
    confirmed    timeout/rejected → (DMS fires → reboot → reverts)
         │
         ▼
  ┌──────────────────────┐
  │ Prerequisites        │  Environmental attestation.
  │ (optional)           │  Tang reachable? TPM valid? Tailscale up?
  │                      │  Shamir threshold: N-of-M must pass.
  └──────┬───────┬───────┘
       pass    fail → (DMS fires → reboot → reverts)
         │
         ▼
  ┌──────────────────────┐
  │ Disarm DMS           │
  │ nixos-rebuild switch │  Generation is now permanent.
  └──────────────────────┘
```

### Why `nixos-rebuild test` instead of `switch`

`test` activates the new generation but does NOT register it as a boot entry. This means:
- A reboot at **any point** during the health check window automatically reverts to the last known-good generation.
- The "rollback" mechanism is just `shutdown -r now` — the simplest, most reliable recovery possible.
- No need to track rollback profiles or run `nix-env --set` to undo the switch.
- Only after confirmation do we run `nixos-rebuild switch` to make it permanent.

### The dead man's switch

A systemd service that sleeps for a configured timeout, then reboots.

```
[service: safe-upgrade-dms]
  ExecStart = sleep $timeout && wall "..." && shutdown -r now
  Type = simple
```

Disarming = `systemctl stop safe-upgrade-dms.service` (kills the sleep, prevents reboot).

The DMS is the **only** rollback mechanism. Everything else — mechanical checks, confirmation — simply decides whether to disarm it. If anything goes wrong at any layer, the DMS fires and the system reboots to safety.

### Mechanical checks

Fast, deterministic, no external dependencies. Run immediately after activation. If any fail, the script exits and the DMS handles rollback.

```bash
sleep 10  # let services stabilize
systemctl is-active openclaw-gateway.service || exit 1
systemctl is-active sshd.service             || exit 1
systemctl is-active tailscaled.service       || exit 1
ss -tlnp | grep -q ':18789 '                || exit 1
ss -tlnp | grep -q ':22 '                   || exit 1
tailscale status --json | jq -e '.Self.Online == true' || exit 1
```

These are the safety net. They catch the class of failure we just experienced (gateway crash loop) without needing any external system to be functional.

## Confirmation modes

After mechanical checks pass, the system needs an external confirmation before making the generation permanent. The confirmation mode is **pluggable** — configured per-host, not hardcoded.

### Mode: `none`

Mechanical checks are sufficient. If they pass, auto-confirm immediately.

```nix
ocd.safe-upgrade.confirm.mode = "none";
```

Flow: mechanical checks pass → disarm DMS → `nixos-rebuild switch`. No external actor involved. Useful for non-critical hosts or as a starting point.

### Mode: `command`

Run an arbitrary command. If it exits 0, the upgrade is confirmed. Lowest-level integration point — can invoke an agent's CLI, hit a local socket, run a test suite, anything.

```nix
ocd.safe-upgrade.confirm.mode = "command";
ocd.safe-upgrade.confirm.command = "${pkgs.openclaw}/bin/openclaw self-test --timeout 30";
```

Examples:
- `openclaw self-test` — agent runs its own verification suite
- `curl -sf http://localhost:18789/health` — hit the gateway's health endpoint
- `/run/current-system/sw/bin/custom-verify` — run a custom script bundled in the generation
- `ssh user@deployer 'echo confirmed'` — verify external connectivity

This is the preferred mode for direct agent integration. If OpenClaw exposes a `self-test` or `health` command, this is the tightest possible coupling without going through a messaging layer.

### Mode: `webhook`

POST to a URL after mechanical checks pass. Wait for a callback to `cancel-rollback`. Decoupled — the receiver decides what to do and when to confirm.

```nix
ocd.safe-upgrade.confirm.mode = "webhook";
ocd.safe-upgrade.confirm.webhookUrl = "https://example.com/hooks/safe-upgrade";
ocd.safe-upgrade.confirm.webhookTokenFile = config.age.secrets.webhook-token.path;
```

Flow:
1. POST `{ host, generation, checks_passed, dms_timeout }` to the webhook URL
2. Receiver (agent platform, CI, monitoring) evaluates
3. Receiver calls back: `POST /cancel-rollback` on a lightweight HTTP listener on the host
4. Or does nothing → DMS fires

Useful for integration with external orchestration systems, CI pipelines, or agent platforms that have their own API.

### Mode: `channel`

Send a message via a messaging platform and wait for a reply. For when the confirmer is an agent or human reachable through a chat protocol.

```nix
ocd.safe-upgrade.confirm.mode = "channel";
ocd.safe-upgrade.confirm.channel = {
  type = "telegram";  # or "whatsapp", "slack", "discord", etc.
  tokenFile = config.age.secrets.telegram-bot-token.path;
  chatId = "7917059187";
  confirmPattern = "CONFIRM";  # regex to match in reply
  rejectPattern = "REJECT";
};
```

Flow:
1. Send message: "Activation on fogell complete. Mechanical checks passed. Reply CONFIRM or REJECT."
2. Poll for reply matching `confirmPattern` or `rejectPattern`
3. CONFIRM → disarm DMS → `nixos-rebuild switch`
4. REJECT → immediate reboot
5. No reply → DMS fires → reboot

Channel adapters are thin scripts. Each adapter implements:
- `send_message(token, chat_id, text)` → message_id
- `poll_reply(token, chat_id, since_message_id, timeout)` → "CONFIRM" | "REJECT" | ""

Adapter implementations for each platform:

| Platform | Send | Poll |
|----------|------|------|
| telegram | `POST /bot$TOKEN/sendMessage` | `GET /bot$TOKEN/getUpdates` |
| whatsapp | WhatsApp Business API or Meta Cloud API | Webhook or polling |
| slack | `POST chat.postMessage` | Socket mode or RTM |
| discord | `POST /channels/$ID/messages` | Gateway websocket |
| ntfy | `POST ntfy.sh/$topic` | `GET ntfy.sh/$topic/json?poll=1` |

### Mode: `manual`

Like switch-fix. Something (human, cron, external system) must run `cancel-rollback` on the host within the timeout. No notification is sent — the caller is expected to know.

```nix
ocd.safe-upgrade.confirm.mode = "manual";
```

A `cancel-rollback` command is installed in the system PATH. Running it disarms the DMS and runs `nixos-rebuild switch`.

### Mode stacking

Modes can be composed. For example: run a command first, then notify via channel.

```nix
ocd.safe-upgrade.confirm.mode = "pipeline";
ocd.safe-upgrade.confirm.pipeline = [
  { mode = "command"; command = "openclaw self-test"; }
  { mode = "channel"; channel = { type = "whatsapp"; chatId = "..."; }; }
];
```

Each step must succeed for the next to run. If any step fails or times out, the remaining steps are skipped and the DMS fires.

This enables flows like:
1. Agent self-test passes (command mode) → confirms the agent is functional
2. Message the user on WhatsApp (channel mode) → "Upgrade on fogell confirmed by agent. All checks passed." → informational, or user can REJECT to force rollback

## Prerequisites (environmental attestation)

Even if a confirmation channel says CONFIRM, `cancel-rollback` should not execute unless the environment itself attests that it's safe. This defends against a compromised confirmation channel — an attacker who gains access to your Telegram bot, WhatsApp, or webhook endpoint cannot force the system to accept a malicious generation if the environmental checks fail.

Prerequisites run **after** confirmation succeeds but **before** `cancel-rollback` executes. They are the final gate.

### Threat model

An attacker who:
- Compromises a Telegram/WhatsApp/Slack bot token
- Gains access to a webhook endpoint
- Intercepts or spoofs a confirmation message

...can send a valid CONFIRM. Without prerequisites, this would cause the system to make a potentially malicious generation permanent. With prerequisites, the attacker would also need to satisfy environmental conditions they can't easily fake (network topology, hardware TPM state, VPN connectivity).

### Prerequisite types

#### `tang` — Network-Bound Attestation

Uses Clevis/Tang to verify the machine is on the expected network. The Tang server must be reachable and the cryptographic exchange must succeed.

```nix
{ type = "tang"; url = "http://tang.tailnet:7654"; }
```

Under the hood: runs `clevis decrypt tang '{"url": "..."}' < /path/to/test-token.jwe` and checks for success. The test token is a small JWE blob encrypted to the Tang server during setup — if it decrypts, the server is reachable and authentic.

Requires:
- A Tang server running on the trusted network (can be another NixOS host with `services.tang.enable = true`)
- `boot.initrd.clevis` is NOT required — this uses Clevis as a runtime attestation tool, not for boot-time disk decryption (though they can coexist)
- The `clevis` package available on the host

#### `tpm` — Hardware Integrity Attestation

Verify that TPM PCR measurements match expected values. Ensures the firmware, bootloader, kernel, and system configuration haven't been tampered with.

```nix
{ type = "tpm"; pcrs = "0+7+12"; }
```

Under the hood: reads PCR values via `tpm2_pcrread` and compares against enrolled expectations, or uses `systemd-cryptenroll`-style verification.

#### `command` — Arbitrary Attestation

Run any command. Exits 0 = attested. Maximum flexibility.

```nix
{ type = "command"; command = "tailscale status --json | jq -e '.Self.Online'"; }
{ type = "command"; command = "test -f /run/secrets/deployment-authorized"; }
{ type = "command"; command = "curl -sf http://internal-ca:8200/v1/sys/health"; }
```

Examples:
- Tailscale is connected (VPN integrity)
- A specific secret file exists (manual authorization flag)
- An internal service is reachable (network topology)
- Time-of-day is within a maintenance window
- A hardware security key is present

#### `clevis-sss` — Shamir Secret Sharing (combining pins)

Use Clevis SSS to combine multiple attestation pins with a threshold. This is Clevis's native composition mechanism.

```nix
{
  type = "clevis-sss";
  threshold = 2;
  pins = {
    tpm2 = {};
    tang = [
      { url = "http://tang1.tailnet:7654"; }
      { url = "http://tang2.tailnet:7654"; }
    ];
  };
}
```

This means: 2 of 3 pins must succeed (TPM + either Tang server, or both Tang servers).

### Configuration

```nix
ocd.safe-upgrade.confirm.prerequisites = [
  { type = "tang"; url = "http://tang.tailnet:7654"; }
  { type = "command"; command = "tailscale status --json | jq -e '.Self.Online'"; }
];

# Shamir-style threshold: how many must pass (default: all)
ocd.safe-upgrade.confirm.prerequisiteThreshold = null;  # null = all must pass
# Or: ocd.safe-upgrade.confirm.prerequisiteThreshold = 2;  # 2-of-N
```

When `prerequisiteThreshold` is null (default), ALL prerequisites must pass. Set it to an integer for N-of-M semantics.

### Execution flow

```
Confirmation says CONFIRM
         │
         ▼
  Run prerequisite checks
         │
         ├─ tang: clevis decrypt succeeds? ✓
         ├─ command: tailscale online? ✓
         ├─ tpm: PCRs match? ✗
         │
  Threshold: 2 of 3 → 2 passed → ✓ ATTESTED
         │
         ▼
  cancel-rollback executes
```

If the threshold is not met:
```
  Threshold: 2 of 3 → 1 passed → ✗ NOT ATTESTED
         │
         ▼
  Log: "Prerequisites not met (1/2 threshold). Refusing confirmation."
  DMS continues → reboot → reverts
```

### Tang server setup (NixOS)

A Tang server can run on any trusted host. For this project, it could run on mclovin (your local machine) or a dedicated server on the Tailscale network:

```nix
# On the Tang server host
services.tang = {
  enable = true;
  ipAddressAllow = "100.0.0.0/8";  # Tailscale CGNAT range only
  listenStream = [ "7654" ];
};
networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 7654 ];
```

```nix
# On fogell (the client)
environment.systemPackages = [ pkgs.clevis pkgs.tang ];
```

During initial setup, create the attestation token:
```bash
echo "safe-upgrade-attestation" | clevis encrypt tang '{"url": "http://mclovin:7654"}' > /etc/safe-upgrade/tang-token.jwe
```

At prerequisite check time:
```bash
clevis decrypt < /etc/safe-upgrade/tang-token.jwe > /dev/null 2>&1
```

If mclovin is reachable on Tailscale → decryption succeeds → prerequisite passes. If fogell is somehow moved off the Tailscale network or mclovin is down → fails → confirmation refused.

## Module interface

```nix
# modules/community/ocd/safe-upgrade.nix
options.ocd.safe-upgrade = {
  enable = mkEnableOption "safe auto-upgrade with health checks and pluggable confirmation";

  flake = mkOption {
    type = types.str;
    default = "github:blessuselessk/determinate-OCD#${config.networking.hostName}";
  };

  interval = mkOption {
    type = types.str;
    default = "*:0/15";
    description = "systemd OnCalendar expression.";
  };

  dmsTimeout = mkOption {
    type = types.int;
    default = 120;
    description = "Dead man's switch timeout in seconds.";
  };

  stabilizeDelay = mkOption {
    type = types.int;
    default = 10;
    description = "Seconds to wait after activation before running mechanical checks.";
  };

  mechanicalChecks = mkOption {
    type = types.listOf types.str;
    default = [];
    description = "Shell commands that must all exit 0. Failure = no confirmation attempted.";
  };

  confirm = {
    mode = mkOption {
      type = types.enum [ "none" "command" "webhook" "channel" "manual" "pipeline" ];
      default = "none";
    };

    command = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Command to run for 'command' mode.";
    };

    webhookUrl = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    webhookTokenFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };

    channel = mkOption {
      type = types.nullOr (types.submodule {
        options = {
          type = mkOption { type = types.enum [ "telegram" "whatsapp" "slack" "discord" "ntfy" ]; };
          tokenFile = mkOption { type = types.path; };
          chatId = mkOption { type = types.str; };
          confirmPattern = mkOption { type = types.str; default = "CONFIRM"; };
          rejectPattern = mkOption { type = types.str; default = "REJECT"; };
        };
      });
      default = null;
    };

    pipeline = mkOption {
      type = types.nullOr (types.listOf types.attrs);
      default = null;
      description = "Ordered list of confirmation steps for 'pipeline' mode.";
    };

    prerequisites = mkOption {
      type = types.listOf (types.submodule {
        options = {
          type = mkOption {
            type = types.enum [ "tang" "tpm" "command" "clevis-sss" ];
          };
          url = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Tang server URL (for 'tang' type).";
          };
          tokenFile = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Path to JWE token file for Tang attestation.";
          };
          pcrs = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "TPM PCR selection (for 'tpm' type). e.g. '0+7+12'.";
          };
          command = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Shell command for 'command' type.";
          };
          threshold = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "Shamir threshold for 'clevis-sss' type.";
          };
          pins = mkOption {
            type = types.nullOr types.attrs;
            default = null;
            description = "Clevis SSS pin configuration.";
          };
        };
      });
      default = [];
      description = "Environmental attestation checks that must pass before cancel-rollback executes.";
    };

    prerequisiteThreshold = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "How many prerequisites must pass. null = all. Integer = N-of-M (Shamir-style).";
    };
  };
};
```

## Host wiring examples

### fogell (critical — agent + human notification + attestation)

```nix
ocd.safe-upgrade = {
  enable = true;
  mechanicalChecks = [
    "systemctl is-active openclaw-gateway.service"
    "systemctl is-active sshd.service"
    "systemctl is-active tailscaled.service"
    "ss -tlnp | grep -q ':18789 '"
  ];
  confirm = {
    mode = "pipeline";
    pipeline = [
      # Agent self-test: tightest integration, no network dependency
      { mode = "command"; command = "openclaw self-test --timeout 30"; }
      # Notify user: informational, with option to reject
      {
        mode = "channel";
        channel = {
          type = "whatsapp";
          tokenFile = config.age.secrets.whatsapp-token.path;
          chatId = "user-phone-number";
        };
      }
    ];

    # Environmental attestation: even if confirmation succeeds,
    # cancel-rollback only executes if the environment checks out.
    prerequisites = [
      # Must be on the Tailscale network (Tang server on mclovin)
      { type = "tang"; url = "http://mclovin:7654";
        tokenFile = config.age.secrets.tang-attestation-token.path; }
      # Tailscale itself must be connected
      { type = "command";
        command = "tailscale status --json | jq -e '.Self.Online'"; }
    ];
    # Both must pass (default: all)
  };
};
```

### A non-critical host (mechanical checks only)

```nix
ocd.safe-upgrade = {
  enable = true;
  mechanicalChecks = [
    "systemctl is-active sshd.service"
  ];
  confirm.mode = "none";
};
```

### A dev host (manual confirmation, like switch-fix)

```nix
ocd.safe-upgrade = {
  enable = true;
  dmsTimeout = 300;  # 5 min to manually verify
  mechanicalChecks = [];
  confirm.mode = "manual";
};
```

## systemd units

### safe-upgrade.timer

```ini
[Timer]
OnCalendar=*:0/15
RandomizedDelaySec=5min
Persistent=true
```

### safe-upgrade.service

Main orchestrator. Runs as root.

```bash
#!/usr/bin/env bash
set -euo pipefail

FLAKE="${cfg.flake}"

echo "=== Building new generation ==="
nixos-rebuild build --flake "$FLAKE" --refresh

echo "=== Activating with test (no boot entry) ==="
nixos-rebuild test --flake "$FLAKE" --refresh

echo "=== Arming dead man's switch (${cfg.dmsTimeout}s) ==="
systemctl start safe-upgrade-dms.service

echo "=== Waiting ${cfg.stabilizeDelay}s for services to stabilize ==="
sleep ${cfg.stabilizeDelay}

echo "=== Running mechanical health checks ==="
# Each check is a separate command; any failure exits the script.
# The DMS remains armed and will reboot after timeout.
${lib.concatMapStringsSep "\n" (check: "${check}") cfg.mechanicalChecks}

echo "=== Mechanical checks passed ==="

# Run confirmation (mode-dependent, generated by the module)
${confirmScript}

echo "=== Confirmation received. Running prerequisite attestation. ==="
# Environmental checks: Tang reachable? TPM valid? Tailscale up?
# Generated from cfg.confirm.prerequisites. Threshold logic applied.
${prerequisiteScript}

echo "=== Prerequisites attested. Making generation permanent. ==="
systemctl stop safe-upgrade-dms.service
nixos-rebuild switch --flake "$FLAKE"
```

### safe-upgrade-dms.service

```ini
[Service]
Type=simple
ExecStart=/bin/sh -c 'sleep ${cfg.dmsTimeout} && wall "safe-upgrade: not confirmed within ${cfg.dmsTimeout}s. Rebooting." && shutdown -r now'
# Hardened: ensure the DMS can always run
MemoryMax=32M
OOMScoreAdjust=-900
```

### cancel-rollback (installed in PATH for manual mode)

Prerequisites are enforced here too — even a manual `cancel-rollback` must pass attestation.

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Running prerequisite attestation..."
${prerequisiteScript}

echo "Prerequisites passed. Disarming DMS and making permanent."
systemctl stop safe-upgrade-dms.service
nixos-rebuild switch --flake "${cfg.flake}"
echo "Generation confirmed and made permanent."
```

## Failure scenarios

| Scenario | What happens |
|----------|-------------|
| Build fails | Script exits before DMS. No change. |
| Activation fails | Script exits before DMS. No change. |
| Service crashes after activation | Mechanical check fails. DMS fires → reboot → reverts. |
| Mechanical checks pass, agent broken | Confirmation times out. DMS fires → reboot → reverts. |
| Mechanical + confirmation pass, prerequisites fail | Attestation fails. DMS fires → reboot → reverts. |
| All layers pass | DMS disarmed. `nixos-rebuild switch`. Permanent. |
| Confirmation channel compromised | Attacker sends CONFIRM, but prerequisites (Tang/TPM/Tailscale) fail → reboot → reverts. |
| Confirmation rejects | Immediate reboot → reverts. |
| Health check script itself crashes | DMS remains armed → reboot → reverts. |
| Power loss during check window | Reboot → last `switch`ed generation (test never registered). |
| Messaging API down | Notification fails. DMS fires → reboot → reverts. |
| Tang server unreachable | Prerequisite fails. DMS fires → reboot → reverts. |
| DMS killed by OOM | Mitigated by MemoryMax + OOMScoreAdjust. |

## Integration with system.autoUpgrade

`ocd.safe-upgrade` **layers on top of** `system.autoUpgrade` (provided by `ocd.autobots-rebuild`) rather than replacing it. The upgrade timer and build logic stay the same. safe-upgrade hooks into the post-activation via `OnSuccess=` on `nixos-upgrade.service`.

Key setting:

```nix
system.autoUpgrade.allowReboot = false;
```

Only the DMS should trigger reboots. If `allowReboot` is true, `autoUpgrade` will reboot on kernel changes, bypassing the entire verification flow.

### How the pieces fit together

```
autobots-rebuild          safe-upgrade
─────────────────         ──────────────────────────────────────
system.autoUpgrade        nixos-upgrade.service OnSuccess=
  builds & switches  ───→   safe-upgrade-verify.service
                              arms DMS
                              runs mechanical checks
                              POSTs to /hooks/agent
                              OpenClaw verifies + cancel-rollback
```

`ocd.safe-upgrade` adds:
- `system.autoUpgrade.allowReboot = false`
- `systemd.services.nixos-upgrade.unitConfig.OnSuccess = [ "safe-upgrade-verify.service" ]`
- `safe-upgrade-verify.service` — arms DMS, runs mechanical checks, notifies OpenClaw
- `safe-upgrade-dms.service` — the dead man's switch
- `cancel-rollback` command in PATH

## Relationship to switch-fix.nix

| | switch-fix | safe-upgrade |
|-|-----------|-------------|
| Activation | `nixos-rebuild switch` (registers boot entry) | `nixos-rebuild test` (no boot entry) |
| Rollback | `nix-env --set` + `switch-to-configuration` | Reboot (always works) |
| Confirmation | Human runs `cancel-rollback` | Pluggable: command, webhook, channel, manual, pipeline |
| Health checks | None | Configurable mechanical checks |
| Failure during rollback | Rollback script could itself fail | Reboot is atomic |

## Future considerations

- **Post-rollback notification**: after a DMS-triggered reboot, detect that a rollback occurred (compare running generation to last attempted) and send a notification explaining what happened.
- **Upgrade history**: structured log of each attempt (generation, checks results, confirmation mode, outcome) for audit and debugging.
- **Backoff**: if N consecutive upgrades trigger rollback, pause auto-upgrade and alert. Prevents a broken `main` from causing a reboot loop.
- **Graduated rollout**: for multi-host fleets, upgrade one host, wait for confirmation, then proceed to others.
- **Pre-activation checks**: run checks *before* activation too (e.g., `nix flake check`, dry-activate) to catch issues earlier.
- **Channel adapters as separate packages**: each messaging platform adapter as its own Nix derivation, reusable across safe-upgrade and review-engine.
