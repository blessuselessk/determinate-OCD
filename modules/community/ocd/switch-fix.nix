# Dead man's switch for safe upgrades.
# Provides: set-rollback, cancel-rollback, switch-fix, boot-fix
# See: github:femtodata/nix-utils
{ inputs, ... }:
{
  flake-file.inputs.nix-utils = {
    url = "github:femtodata/nix-utils";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  ocd.switch-fix.nixos = {
    imports = [ inputs.nix-utils.nixosModules.switch-fix ];
    system.autoUpgrade.allowReboot = false;
  };
}
