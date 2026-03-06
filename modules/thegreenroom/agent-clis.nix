# Agent CLI tools from clempat/ai-tools-flake.
# Installs: opencode, beads, bdui, ccusage.
# agent-browser is Linux-only.
{ inputs, ... }:
{
  flake-file.inputs.ai-tools-flake = {
    url = "github:clempat/ai-tools-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  thegreenroom.agent-clis = {
    homeManager =
      { pkgs, lib, ... }:
      let
        ai = inputs.ai-tools-flake.packages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        home.packages =
          [
            ai.opencode
            ai.beads
            ai.bdui
            ai.ccusage
          ]
          ++ lib.optionals pkgs.stdenv.isLinux [ ai.agent-browser ];
      };
  };
}
