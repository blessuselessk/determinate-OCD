{
  ocd.networking.nixos =
    { lib, ... }:
    {
      networking.networkmanager.enable = true;
      networking.useDHCP = lib.mkDefault true;
      networking.firewall.allowedTCPPorts = [
        443 # HTTPS (reverse proxy for OpenClaw gateway)
        22 # SSH (Determinate remote deploy)
      ];
    };
}
