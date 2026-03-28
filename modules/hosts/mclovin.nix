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
      nix.distributedBuilds = true;
      nix.buildMachines = [
        {
          hostName = "fogell.serval-minor.ts.net";
          systems = [ "x86_64-linux" "aarch64-linux" ];
          sshUser = "root";
          protocol = "ssh-ng";
          maxJobs = 2;
        }
      ];
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
      lessuseless.claude
      lessuseless.secrets
      lessuseless.shell
      lessuseless.ssh
    ];
  };
}
