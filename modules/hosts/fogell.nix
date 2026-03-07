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
      { config, ... }:
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

        # Gateway service config
        services.openclaw-gateway = {
          environmentFiles = [ config.age.secrets.openclaw-gateway-token.path ];
          config.gateway.mode = "local";
          config.gateway.tailscale.mode = "serve"; # HTTPS via tailscale serve — handles TLS + device pairing
          config.gateway.controlUi.allowedOrigins = [
            "https://fogell:18789"
            "https://100.98.82.19:18789"
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
