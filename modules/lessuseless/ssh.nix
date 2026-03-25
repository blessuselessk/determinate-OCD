{ ... }:
{
  lessuseless.ssh = {
    nixos = {
      users.users.lessuseless.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQnPq/vY1gN4IvQf6jBCu6jJWULmIVnKjKoxZxpxakO lessuseless@mclovin"
      ];
    };

    homeManager = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks.fogell = {
          hostname = "fogell.serval-minor.ts.net";
          user = "root";
        };
        matchBlocks."*" = {
          addKeysToAgent = "yes";
          identityFile = "~/.ssh/id_ed25519";
          extraOptions = {
            UseKeychain = "yes";
          };
        };
      };
    };
  };
}
