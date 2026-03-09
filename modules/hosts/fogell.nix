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
      ocd.determinate
      ocd.networking
      ocd.openclaw-gateway
      ocd.remote-access
      ocd.switch-fix
      ocd.tailguard
    ];
    nixos =
      { config, pkgs, ... }:
      {
        # EC2 Graviton instance — boot config
        boot.loader.grub.enable = false;
        boot.loader.systemd-boot.enable = false;
        fileSystems."/" = {
          device = "/dev/xvda1";
          fsType = "ext4";
        };
        networking.hostName = "fogell";
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
              printf 'OPENCLAW_GATEWAY_TOKEN=%s\n' "$(cat ${config.age.secrets.openclaw-gateway-token.path})" > /run/openclaw-gateway.env
              chmod 400 /run/openclaw-gateway.env
              chown openclaw:openclaw /run/openclaw-gateway.env
            '';
          };
        };

        # Gateway service config
        services.openclaw-gateway = {
          environmentFiles = [ "/run/openclaw-gateway.env" ];
          config.gateway.mode = "local";
          config.gateway.bind = "loopback";
          config.gateway.auth.mode = "trusted-proxy"; # Tailscale Serve handles identity — bypasses device signature checks
          config.gateway.auth.allowTailscale = true; # Tailscale identity headers as auth
          config.gateway.auth.trustedProxy.userHeader = "Tailscale-User-Login"; # Tailscale Serve passes identity headers
          config.gateway.trustedProxies = [ "127.0.0.1" ]; # Tailscale Serve is a local reverse proxy
          config.gateway.tailscale.mode = "serve"; # HTTPS via tailscale serve — handles TLS + device identity
          config.gateway.controlUi.dangerouslyDisableDeviceAuth = true; # safe: gateway secured by Tailscale + loopback
          config.gateway.controlUi.allowedOrigins = [
            "https://fogell.serval-minor.ts.net"
            "https://100.98.82.19"
            "https://localhost:18789"
            "https://127.0.0.1:18789"
          ];
          config.channels.telegram = {
            enabled = true;
            tokenFile = config.age.secrets.telegram-bot-token.path;
            allowFrom = [ 7917059187 ];
          };
        };
      };
  };

  den.aspects.lessuseless = {
    includes = [
      den.provides.primary-user
      lessuseless.secrets
    ];
  };
}
