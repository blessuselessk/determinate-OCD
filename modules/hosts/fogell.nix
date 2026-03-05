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
      ocd.determinate
      ocd.networking
      ocd.openclaw-gateway
      ocd.tailscale
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

        # SSH for agenix identity + remote management
        services.openssh.enable = true;

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

        # Gateway service config
        services.openclaw-gateway = {
          environmentFiles = [ config.age.secrets.openclaw-gateway-token.path ];
          config.gateway.mode = "local";
          config.channels.telegram = {
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
