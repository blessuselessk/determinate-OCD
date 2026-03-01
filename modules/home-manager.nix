{ den, ... }:
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.default.includes = [
    den._.home-manager
    den._.inputs'
    den._.self'
  ];
}
