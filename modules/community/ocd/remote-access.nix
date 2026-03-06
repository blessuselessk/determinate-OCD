# Remote access: SSH hardening + Mosh + Tailscale.
# Authorized keys: add to users.users.root.openssh.authorizedKeys.keys
# in the host or user aspect (NixOS list-merging applies).
{ ocd, ... }:
{
  ocd.remote-access = {
    includes = [ ocd.tailscale ];

    # NixOS: SSH hardening + mosh server + firewall.
    nixos =
      { ... }:
      {
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "prohibit-password";
          };
        };

        # Mosh: mobile shell for roaming connections. Opens UDP 60000-61000.
        programs.mosh.enable = true;

        # SSH port co-located here since this aspect owns SSH.
        networking.firewall.allowedTCPPorts = [ 22 ];
      };

    # macOS: mosh client only.
    darwin =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.mosh ];
      };
  };
}
