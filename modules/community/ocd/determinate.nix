# Determinate Nix: enterprise Nix distribution with flakes, parallel eval, FlakeHub cache.
# Note: do NOT follow nixpkgs — Determinate pins its own for cache hits.
{ inputs, ... }:
{
  flake-file.inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

  ocd.determinate = {
    nixos = {
      imports = [ inputs.determinate.nixosModules.default ];
      determinate.enable = true;
    };
    darwin = {
      imports = [ inputs.determinate.darwinModules.default ];
      nix.enable = false;
      determinateNix.enable = true;
    };
  };
}
