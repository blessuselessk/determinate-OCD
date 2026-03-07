# GP2 Gateway: OpenClaw as a NixOS system service.
# Secrets and channel config are wired per-host (see fogell.nix).
# For the client aspect, see openclaw.nix.
{ inputs, ... }:
{
  ocd.openclaw-gateway.nixos =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [ inputs.nix-openclaw.overlays.default ];
      imports = [ inputs.nix-openclaw.nixosModules.openclaw-gateway ];

      environment.systemPackages = [
        inputs.nix-openclaw.packages.${pkgs.stdenv.hostPlatform.system}.openclaw-gateway
      ];

      services.openclaw-gateway = {
        enable = true;
        package = inputs.nix-openclaw.packages.${pkgs.stdenv.hostPlatform.system}.openclaw-gateway;

        # The upstream module creates /etc/openclaw owned by root:root via tmpfiles.
        # The gateway runs as the `openclaw` user and needs to write temp files there
        # (atomic write pattern). This chown runs as root ('+' prefix) before each start.
        #
        # Must use the module's `execStartPre` option — setting
        # systemd.services.*.serviceConfig.ExecStartPre directly gets overridden by
        # the module's own empty-list default for that key.
        execStartPre = [ "+${pkgs.coreutils}/bin/chown -R openclaw:openclaw /etc/openclaw" ];
      };

      # Harden the gateway system service.
      # Note: MemoryDenyWriteExecute omitted — Go runtime requires W+X memory.
      # ProtectSystem = "strict" makes /etc read-only for the service; ReadWritePaths
      # whitelists /etc/openclaw for the gateway's atomic config writes.
      # tailscale serve: the gateway needs the CLI in PATH and operator
      # permissions on the tailscale daemon socket.
      services.tailscale.extraSetFlags = [ "--operator=openclaw" ];
      systemd.services.openclaw-gateway.path = [ pkgs.tailscale ];

      systemd.services.openclaw-gateway.serviceConfig = {
        ProtectSystem = "strict";
        ReadWritePaths = [ "/etc/openclaw" "/var/lib/openclaw" ];
        ProtectHome = "read-only";
        PrivateTmp = true;
        NoNewPrivileges = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        ProtectClock = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        SystemCallArchitectures = "native";
      };
    };
}
