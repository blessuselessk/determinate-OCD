{ den, ocd, ... }:
{
  den.aspects.ocd-dev = {
    includes = [
      (den.provides.tty-autologin "admin")
      ocd.agenix
      ocd.determinate
      ocd.nodocs
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
