{
  den,
  ocd,
  lessuseless,
  ...
}:
{
  den.aspects.fogell = {
    includes = [
      ocd.agenix
      ocd.autobots-rebuild
      ocd.cachix
      ocd.determinate
      ocd.networking
      ocd.nodocs
      ocd.openclaw-gateway
      ocd.remote-access
      ocd.switch-fix
      ocd.tailguard
    ];
    nixos =
      {
        config,
        pkgs,
        lib,
        modulesPath,
        ...
      }:
      {
        # EC2 instance — import the NixOS EC2 module for proper boot,
        # filesystem, and metadata handling across instance types.
        imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
        ec2.hvm = true;
        networking.hostName = "fogell";
        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQnPq/vY1gN4IvQf6jBCu6jJWULmIVnKjKoxZxpxakO lessuseless@mclovin"
        ];
        networking.networkmanager.enable = lib.mkForce false; # Conflicts with EC2 networking
        networking.dhcpcd.extraConfig = "nohook hostname";
        system.stateVersion = "25.05";

        # Gateway secrets — owned by the openclaw system user
        age.secrets.openclaw-gateway-token = {
          file = ../lessuseless/secrets/openclaw-gateway-token.age;
          owner = "openclaw";
          mode = "0400";
        };
        age.secrets.telegram-bot-token = {
          file = ../lessuseless/secrets/telegram-bot-token.age;
          owner = "openclaw";
          mode = "0400";
        };
        age.secrets.wg-warp-key = {
          file = ../lessuseless/secrets/wg-warp-key.age;
          mode = "0600";
        };
        age.secrets.minimax-api-key = {
          file = ../lessuseless/secrets/minimax-api-key.age;
          owner = "openclaw";
          mode = "0400";
        };
        age.secrets.discord-bot-token = {
          file = ../lessuseless/secrets/discord-bot-token.age;
          owner = "openclaw";
          mode = "0400";
        };
        age.secrets.github-pat-openclaw = {
          file = ../lessuseless/secrets/github-pat-openclaw.age;
          owner = "openclaw";
          mode = "0400";
        };

        # Tailguard: WARP exit node IPs from wgcf-profile.conf
        networking.wireguard.interfaces.wg-warp.ips = [
          "172.16.0.2/32"
        ];

        # Oneshot service creates env file from agenix secret BEFORE gateway starts.
        # (EnvironmentFile= is read before ExecStartPre, so we can't do it inline.)
        systemd.services.openclaw-gateway-env = {
          description = "Create openclaw gateway env file from agenix secret";
          before = [ "openclaw-gateway.service" ];
          requiredBy = [ "openclaw-gateway.service" ];
          after = [ "agenix.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = pkgs.writeShellScript "openclaw-gateway-env" ''
              printf 'OPENCLAW_GATEWAY_TOKEN=%s\nMINIMAX_API_KEY=%s\nGITHUB_TOKEN=%s\n' \
                "$(cat ${config.age.secrets.openclaw-gateway-token.path})" \
                "$(cat ${config.age.secrets.minimax-api-key.path})" \
                "$(cat ${config.age.secrets.github-pat-openclaw.path})" \
                > /run/openclaw-gateway.env
              chmod 400 /run/openclaw-gateway.env
              chown openclaw:openclaw /run/openclaw-gateway.env
            '';
          };
        };

        # Provision workspace: _system/ is immutable (overwritten each rebuild),
        # templates are seeded once (agent evolves them), agent state is never touched.
        systemd.services.openclaw-workspace-init = {
          description = "Provision OpenClaw workspace documents";
          before = [ "openclaw-gateway.service" ];
          requiredBy = [ "openclaw-gateway.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = pkgs.writeShellScript "openclaw-workspace-init" ''
              WS=/var/lib/openclaw/.openclaw/workspace

              # Firmware — always overwrite (read-only, nix-managed)
              install -d -m 0555 -o openclaw -g openclaw "$WS/_system"
              install -m 0444 -o openclaw -g openclaw \
                ${../community/ocd/_helpers/workspace/_system/AGENTS.md} \
                "$WS/_system/AGENTS.md"
              install -m 0444 -o openclaw -g openclaw \
                ${../community/ocd/_helpers/workspace/_system/SOUL.md} \
                "$WS/_system/SOUL.md"
              install -m 0444 -o openclaw -g openclaw \
                ${../community/ocd/_helpers/workspace/_system/USER.md} \
                "$WS/_system/USER.md"
              install -m 0444 -o openclaw -g openclaw \
                ${../community/ocd/_helpers/workspace/_system/TOOLS.md} \
                "$WS/_system/TOOLS.md"

              # Templates — seed once, agent evolves.
              # Mutable wrappers that @[import] from _system/.
              test -f "$WS/AGENTS.md" || \
                install -m 0644 -o openclaw -g openclaw \
                  ${../community/ocd/_helpers/workspace/AGENTS.md} \
                  "$WS/AGENTS.md"
              test -f "$WS/SOUL.md" || \
                install -m 0644 -o openclaw -g openclaw \
                  ${../community/ocd/_helpers/workspace/SOUL.md} \
                  "$WS/SOUL.md"
              test -f "$WS/USER.md" || \
                install -m 0644 -o openclaw -g openclaw \
                  ${../community/ocd/_helpers/workspace/USER.md} \
                  "$WS/USER.md"
              test -f "$WS/TOOLS.md" || \
                install -m 0644 -o openclaw -g openclaw \
                  ${../community/ocd/_helpers/workspace/TOOLS.md} \
                  "$WS/TOOLS.md"
              test -f "$WS/HEARTBEAT.md" || \
                install -m 0644 -o openclaw -g openclaw \
                  ${../community/ocd/_helpers/workspace/HEARTBEAT.md} \
                  "$WS/HEARTBEAT.md"
            '';
          };
        };

        # Restart gateway after any activation that changes the config,
        # so ExecStartPre re-injects secrets into the fresh template.
        systemd.services.openclaw-gateway.restartTriggers = [
          config.environment.etc."openclaw/openclaw.json".source
        ];

        # Redirect config path to /run (outside environment.etc management).
        # The gateway detects "Nix mode" when /etc/static/openclaw/openclaw.json
        # exists as a Nix store symlink, then re-reads the template on every start,
        # clobbering injected secrets. Using /run/ avoids this detection.
        systemd.services.openclaw-gateway.environment = {
          OPENCLAW_CONFIG_PATH = lib.mkForce "/run/openclaw/config.json";
          CLAWDBOT_CONFIG_PATH = lib.mkForce "/run/openclaw/config.json";
        };

        # Gateway service config
        services.openclaw-gateway = {
          environmentFiles = [ "/run/openclaw-gateway.env" ];
          config.gateway.mode = "local";
          config.gateway.bind = "loopback";
          config.gateway.trustedProxies = [ "127.0.0.1" ]; # Tailscale Serve is a local reverse proxy
          config.gateway.tailscale.mode = "serve"; # HTTPS via tailscale serve — handles TLS + device identity
          config.gateway.controlUi.dangerouslyDisableDeviceAuth = true; # safe: gateway secured by Tailscale + loopback
          config.gateway.controlUi.allowedOrigins = [
            "https://fogell.serval-minor.ts.net"
            "https://100.82.214.16"
            "https://localhost:18789"
            "https://127.0.0.1:18789"
          ];
          config.channels.telegram = {
            enabled = true;
            tokenFile = config.age.secrets.telegram-bot-token.path;
            allowFrom = [ 7917059187 ];
          };
          # Secret injection for channels that lack tokenFile support.
          #
          # OpenClaw's gateway supports `tokenFile` for Telegram (the app reads the file
          # at startup), but not for Discord or other channels. Putting plaintext tokens
          # in Nix config leaks them to the world-readable nix store.
          #
          # Workaround: use a placeholder in the Nix-generated config JSON, then replace
          # it with the real secret via a root-privileged ExecStartPre script that runs
          # before every gateway start. This is the standard agenix pattern for services
          # that don't support secret file references.
          #
          # Upstream: https://github.com/openclaw/openclaw/issues/56397
          # (tokenFile should be supported for all channel account types, not just Telegram)
          #
          # When upstream adds tokenFile for Discord, replace this block with:
          #   accounts.default = { enabled = true; tokenFile = config.age.secrets.discord-bot-token.path; };
          # and remove the ExecStartPre inject-secrets script below.
          config.channels.discord = {
            accounts.default = {
              enabled = true;
              token = "__DISCORD_BOT_TOKEN__";
            };
            groupPolicy = "allowlist";
            guilds."1486572020824281180" = {
              requireMention = true;
              users = [ "1483775972938354778" ];
            };
            dm = {
              enabled = true;
              allowFrom = [ "1483775972938354778" ];
            };
          };

          # MiniMax model providers
          config.models.providers = {
            minimax = {
              baseUrl = "https://api.minimax.io/anthropic";
              models = [
                {
                  id = "MiniMax-M2.7";
                  name = "MiniMax-M2.7";
                  contextWindow = 200000;
                }
              ];
            };
            minimax-portal = {
              baseUrl = "https://api.minimax.io/anthropic";
              apiKey = "minimax-oauth";
              api = "anthropic-messages";
              models = [
                {
                  id = "MiniMax-M2.1";
                  name = "MiniMax M2.1";
                  reasoning = false;
                  input = [ "text" ];
                  cost = {
                    input = 0;
                    output = 0;
                    cacheRead = 0;
                    cacheWrite = 0;
                  };
                  contextWindow = 200000;
                  maxTokens = 8192;
                }
                {
                  id = "MiniMax-M2.5";
                  name = "MiniMax M2.5";
                  reasoning = true;
                  input = [ "text" ];
                  cost = {
                    input = 0;
                    output = 0;
                    cacheRead = 0;
                    cacheWrite = 0;
                  };
                  contextWindow = 200000;
                  maxTokens = 8192;
                }
              ];
            };
          };

          # Agent defaults — route to MiniMax
          config.agents.defaults = {
            model = {
              primary = "minimax-portal/MiniMax-M2.5";
              fallbacks = [
                "minimax/MiniMax-M2.7"
                "minimax-portal/MiniMax-M2.1"
              ];
            };
            models = {
              "minimax/MiniMax-M2.7" = { };
              "minimax-portal/MiniMax-M2.1" = {
                alias = "minimax-m2.1";
              };
              "minimax-portal/MiniMax-M2.5" = {
                alias = "minimax-m2.5";
              };
            };
          };

          # MiniMax OAuth plugin
          config.plugins.entries.minimax-portal-auth.enabled = true;
          config.auth.profiles."minimax-portal:default" = {
            provider = "minimax-portal";
            mode = "oauth";
          };

          # Inject secrets into a runtime config at /run/openclaw/config.json.
          # The gateway env vars are redirected there (see above) to avoid Nix mode:
          # when the config lives under /etc with a /etc/static/ symlink, the gateway
          # re-reads the Nix store template on every start, clobbering injected secrets.
          execStartPre = [
            "+${pkgs.writeShellScript "openclaw-inject-secrets" ''
              mkdir -p /run/openclaw
              cp ${config.environment.etc."openclaw/openclaw.json".source} /run/openclaw/config.json
              chmod 0644 /run/openclaw/config.json
              chown openclaw:openclaw /run/openclaw/config.json
              ${pkgs.gnused}/bin/sed -i \
                "s|__DISCORD_BOT_TOKEN__|$(cat ${config.age.secrets.discord-bot-token.path})|" \
                /run/openclaw/config.json
            ''}"
          ];
        };

        # Dead man's switch: arm before auto-upgrade, auto-cancel via health check.
        # Flow: arm DMS + write DMS.md → upgrade runs → agent or cron cancels.
        systemd.services.dms-arm = {
          description = "Arm dead man's switch before upgrade";
          before = [ "nixos-upgrade.service" ];
          requiredBy = [ "nixos-upgrade.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = pkgs.writeShellScript "dms-arm" ''
              # Arm the DMS (save current system for rollback)
              ln -sf $(readlink /run/current-system) /var/lib/nix-autorollback/profile-switch

              # Inject into OpenClaw agent context
              cat > /var/lib/openclaw/.openclaw/workspace/DMS.md << 'DMSEOF'
              # Dead Man's Switch — Armed

              A NixOS upgrade is running. The dead man's switch is armed.
              Run `dms-disarm` to confirm the system is healthy and disarm.
              DMSEOF
              chown openclaw:openclaw /var/lib/openclaw/.openclaw/workspace/DMS.md
            '';
          };
        };

        # Health check cron: if DMS is armed and system is healthy, cancel it.
        # The agent is the primary check (sees DMS.md); this cron is the fallback.
        systemd.services.dms-check = {
          description = "Cancel DMS if system is healthy";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = pkgs.writeShellScript "dms-check" ''
              DMS_FILE="/var/lib/openclaw/.openclaw/workspace/DMS.md"
              ROLLBACK="/var/lib/nix-autorollback/profile-switch"
              if [ -e "$ROLLBACK" ] || [ -f "$DMS_FILE" ]; then
                systemctl stop nix-autorollback.service 2>/dev/null || true
                rm -f /var/lib/nix-autorollback/profile-switch
                rm -f /var/lib/nix-autorollback/profile
                rm -f "$DMS_FILE"
              fi
            '';
          };
        };
        environment.systemPackages = [
          (pkgs.writeShellScriptBin "dms-disarm" ''
            systemctl start dms-check
          '')
        ];

        systemd.timers.dms-check = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "*:0/5";
            Persistent = true;
          };
        };
      };
  };

  den.aspects.lessuseless = {
    includes = [
      den.provides.primary-user
      lessuseless.ssh
      lessuseless.secrets
    ];
  };
}
