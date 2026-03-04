{
  ocd.networking.nixos =
    { lib, ... }:
    {
      networking.networkmanager.enable = true;
      networking.useDHCP = lib.mkDefault true;
      # Public firewall: SSH only. All other services are Tailscale-only
      # (tailscale0 is trusted via ocd.tailscale).
      networking.firewall.allowedTCPPorts = [ 22 ];
    };
}
