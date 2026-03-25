{
  den,
  ocd,
  lair,
  lessuseless,
  ...
}:
{
  den.aspects.mclovin = {
    includes = [
      ocd.agenix
      ocd.cachix
      ocd.determinate
      ocd.homebrew
      ocd.nodocs
      ocd.openclaw
      ocd.remote-access
    ];
    darwin = {
      system.stateVersion = 6;
      security.pam.services.sudo_local.touchIdAuth = true;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-bak";
    };
    homeManager =
      { lib, ... }:
      {
        home.homeDirectory = lib.mkForce "/Users/lessuseless";
      };
  };

  den.aspects.lessuseless = {
    includes = [
      den.provides.primary-user
      lessuseless.direnv
      lessuseless.gh
      lessuseless.git
      lessuseless.jujutsu
      lair.jj-guard
      lessuseless.secrets
      lessuseless.shell
      lessuseless.ssh
    ];
  };
}
