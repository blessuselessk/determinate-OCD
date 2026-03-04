{ inputs, ... }:
{
  flake-file.inputs.agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  ocd.agenix = {
    nixos = {
      imports = [ inputs.agenix.nixosModules.default ];
    };
    darwin = {
      imports = [ inputs.agenix.darwinModules.default ];
    };
  };
}
