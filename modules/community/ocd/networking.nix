{
  ocd.networking.nixos =
    { lib, ... }:
    {
      networking.networkmanager.enable = true;
      networking.useDHCP = lib.mkDefault true;
      # Public firewall: SSH and Mosh are managed by ocd.remote-access.
      # All other services are Tailscale-only (tailscale0 trusted via ocd.tailscale).
    };
}
