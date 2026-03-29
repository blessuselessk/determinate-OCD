# GitOps: periodic self-upgrade from the GitHub flake.
# Add to any host's includes; flake attr is derived from networking.hostName.
{ ... }:
{
  ocd.autobots-rebuild = {
    nixos =
      { config, ... }:
      {
        system.autoUpgrade = {
          enable = true;
          flake = "github:blessuselessk/determinate-OCD#${config.networking.hostName}";
          flags = [ "--refresh" ];
          dates = "*:0/15";
          randomizedDelaySec = "5min";
        };
      };
  };
}
