# Determinate Nix: enterprise Nix distribution with flakes, parallel eval, FlakeHub cache.
# Note: do NOT follow nixpkgs — Determinate pins its own for cache hits.
{ inputs, ... }:
{
  flake-file.inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

  ocd.determinate = {
    nixos = {
      imports = [ inputs.determinate.nixosModules.default ];
    };
    darwin = {
      imports = [ inputs.determinate.darwinModules.default ];
      determinateNix.enable = true;
    };
  };
}
