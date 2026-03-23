{ den, lib, ... }:
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.default.includes = [
    den._.inputs'
    den._.self'
  ];
}
