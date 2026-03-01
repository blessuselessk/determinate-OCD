{ inputs, lib, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  flake-file.inputs = {
    treefmt-nix.url = lib.mkDefault "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = lib.mkDefault "nixpkgs";
  };

  perSystem =
    { ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          deadnix.enable = true;
        };
        settings.on-unmatched = lib.mkDefault "info";
      };
    };
}
