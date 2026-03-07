{
  flake-file.inputs.darwin = {
    url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.2511.*";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
