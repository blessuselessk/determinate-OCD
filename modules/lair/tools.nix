# MCP servers via mcp-servers-nix.
{ inputs, ... }:
{
  flake-file.inputs.mcp-servers-nix = {
    url = "github:natsukium/mcp-servers-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  lair.tools = {
    homeManager =
      { ... }:
      {
        imports = [ inputs.mcp-servers-nix.homeManagerModules.default ];
      };
  };
}
