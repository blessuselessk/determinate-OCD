{
  den,
  ocd,
  lessuseless,
  ...
}:
{
  den.aspects.mclovin = {
    includes = [
      ocd.agenix
      ocd.determinate
      ocd.homebrew
      ocd.openclaw-app
      ocd.remote-access
    ];
    darwin = {
      system.stateVersion = 6;
      security.pam.services.sudo_local.touchIdAuth = true;
      home-manager.useGlobalPkgs = true;
      home-manager.backupFileExtension = "before-nix-darwin";
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
      lessuseless.gh
      lessuseless.git
      lessuseless.jujutsu
      lessuseless.secrets
      lessuseless.shell
    ];
  };
}
