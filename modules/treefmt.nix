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
          mdformat = {
            enable = true;
            excludes = [
              ".ai/output/*"
              ".ai/AGENTS.md"
              ".ai/agents/*.md"
              ".ai/instructions/*.md"
              ".ai/workflows/*.md"
              ".ai/skills/*/SKILL.md"
              ".ai/memory/AGENTS.md"
              ".ai/prompts/AGENTS.md"
              ".ai/skills/AGENTS.md"
              ".ai/specs/AGENTS.md"
              ".ai/context/AGENTS.md"
              ".ai/context/references/deps/*.md"
              ".github/**/*.md"
            ];
          };
          yamlfmt.enable = true;
          taplo.enable = true;
          prettier = {
            enable = true;
            includes = [ "*.json" ];
          };
        };
        settings.on-unmatched = lib.mkDefault "info";
      };
    };
}
