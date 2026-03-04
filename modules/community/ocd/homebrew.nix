# Declarative Homebrew management via nix-homebrew.
# Pins Homebrew version and taps. Use nix-darwin's homebrew.* for packages.
{ inputs, ... }:
{
  flake-file.inputs = {
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  ocd.homebrew.darwin =
    { config, ... }:
    {
      imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

      nix-homebrew = {
        enable = true;
        enableRosetta = true;
        autoMigrate = true;
        user = builtins.head (builtins.attrNames config.home-manager.users);
        taps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
        };
        mutableTaps = false;
      };
    };
}
