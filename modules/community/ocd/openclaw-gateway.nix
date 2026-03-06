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

      services.openclaw-gateway = {
        enable = true;
        package = inputs.nix-openclaw.packages.${pkgs.stdenv.hostPlatform.system}.openclaw-gateway;
      };

      # Harden the gateway system service
      # Note: MemoryDenyWriteExecute omitted — Go runtime requires W+X memory
      # ExecStartPre ('+' = runs as root) fixes upstream module creating /etc/openclaw as root:root
      systemd.services.openclaw-gateway.serviceConfig = {
        ExecStartPre = [ "+${pkgs.coreutils}/bin/chown openclaw:openclaw /etc/openclaw" ];
        ProtectSystem = "strict";
        ReadWritePaths = [ "/etc/openclaw" ];
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
