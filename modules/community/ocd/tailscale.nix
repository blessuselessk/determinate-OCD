{
  ocd.tailscale = {
    nixos = {
      services.tailscale.enable = true;
      networking.firewall.trustedInterfaces = [ "tailscale0" ];
    };
    darwin = {
      services.tailscale.enable = true;
    };
  };
}
