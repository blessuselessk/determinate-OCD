# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    agenix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ryantm/agenix";
    };
    darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.2511.*";
    };
    den.url = "github:vic/den";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    flake-aspects.url = "github:vic/flake-aspects";
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
      url = "github:hercules-ci/flake-parts";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };
    homebrew-cask = {
      flake = false;
      url = "github:homebrew/homebrew-cask";
    };
    homebrew-core = {
      flake = false;
      url = "github:homebrew/homebrew-core";
    };
    import-tree.url = "github:vic/import-tree";
    jjui.url = "github:idursun/jjui";
    mcp-servers-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:natsukium/mcp-servers-nix";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-openclaw = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:arubis/nix-openclaw/fix/rolldown-sandbox-shim";
    };
    nix-utils = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:femtodata/nix-utils";
    };
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    nixpkgs-lib.follows = "nixpkgs";
    nuenv.url = "github:xav-ie/nuenv";
    promptyst = {
      flake = false;
      url = "github:blessuselessk/promptyst";
    };
    treefmt-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/treefmt-nix";
    };
  };

}
