# Placeholder aspect for the ocd-dev host.
# Replace with real config when deploying to actual hardware.
{ den, ... }:
{
  den.aspects.ocd-dev = {
    includes = [
      (den.provides.tty-autologin "admin")
    ];
    nixos = {
      boot.loader.grub.enable = false;
      fileSystems."/".device = "/dev/fake";
    };
  };

  den.aspects.admin = {
    includes = [
      den.provides.primary-user
    ];
  };
}
