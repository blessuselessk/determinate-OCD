# den-tools: ecosystem tooling for aspect authoring and remote repo ingestion.
#
# Tool inputs (usable CLIs and libraries):
#
#   nixtract (github:tweag/nixtract)
#     CLI that extracts the full derivation dependency graph from a Nix flake
#     as structured JSONL. Use it to audit transitive deps, scan licenses, and
#     map which derivations an aspect pulls in.
#     Syntax: nixtract [-f <flake-ref>] [-a <attr-path>] [-s <system>] [output.jsonl]
#
#   flakelight (github:nix-community/flakelight)
#     Modular flake framework that auto-generates per-system outputs, overlays,
#     and devShells from minimal declarations. Reference for studying flake
#     patterns, prototyping packages, and comparing module composition approaches.
#     Syntax: flakelight ./. { devShell.packages = pkgs: [ ... ]; }
#
#   nix-effects (github:kleisli-io/nix-effects)
#     Type-checking kernel with algebraic effects and dependent types in pure
#     Nix. Catches config errors at eval time via refinement types and cross-field
#     validation. Use for typed contracts between aspects and policy enforcement.
#     Syntax: let fx = nix-effects.lib; in fx.types.refined "Port" fx.types.Int (x: x >= 1 && x <= 65535)
#
#   nix-filter (github:numtide/nix-filter)
#     Source filtering library for Nix derivations. Controls which files enter
#     the Nix store for builds. Replaces manual cleanSource patterns.
#     Syntax: nix-filter { root = ./.; include = [ "src" (nix-filter.matchExt "nix") ]; }
#
#   namaka (github:nix-community/namaka)
#     Snapshot testing for Nix expressions. Serializes eval results and diffs
#     against stored snapshots. Integrates as a flake check.
#     Syntax: namaka check | namaka review | namaka clean
#
#   nix-plugins (github:shlevy/nix-plugins)
#     Native plugins for the Nix evaluator. Adds extra builtins via shared
#     libraries. Use for extending Nix with custom primops.
#     Syntax: nix.extraOptions = "plugin-files = ${pkgs.nix-plugins}/lib/nix/plugins/libnix-extra-builtins.so";
#
#   rnix-parser (github:nix-community/rnix-parser)
#     Lossless Nix parser in Rust (rowan-based). Produces concrete syntax trees
#     preserving whitespace and comments. Foundation for formatters and LSPs.
#     Syntax: let parse = rnix::Root::parse(src); parse.syntax().descendants()
#
#   claude-code-lsps (github:boostvolt/claude-code-lsps)
#     LSP plugin marketplace for Claude Code. Provides language server configs
#     for 23+ languages via .lsp.json schema.
#     Syntax: /plugin marketplace add <language>
#
#   attr-cmd (github:fricklerhandwerk/attr-cmd)
#     Declarative CLI construction from Nix attribute sets. Turns nested attrsets
#     into subcommands with auto-generated help text.
#     Syntax: lib.attr-cmd.exec { subcmd = { meta.description = "..."; action = "..."; }; }
#
#   nixpkgs-review (github:Mic92/nixpkgs-review)
#     CLI for reviewing nixpkgs pull requests. Builds affected packages locally
#     and posts results. Essential for nixpkgs contribution workflow.
#     Syntax: nixpkgs-review pr <number> [--post-result] | nixpkgs-review rev HEAD | nixpkgs-review wip
#
# Reference-only (doc deps, not flake inputs):
#   flake-utils, flake-utils-plus, nixseparatedebuginfod, POP, korora,
#   agentDiagram, denix, devour-flake, rime, thaw, nix-melt, flake-checker,
#   nixt, nh, nvd, dix, nix-output-monitor, nixos-cli, nxv, nix-manipulator,
#   deploy-flake, nixfzf, purga, clap-nix, jaillm, noogle, patsh
#   See .ai/context/references/deps/ for full documentation.
#
{ ... }:
{
  flake-file.inputs = {
    nixtract = {
      url = "github:tweag/nixtract";
      flake = false;
    };
    flakelight = {
      url = "github:nix-community/flakelight";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-effects = {
      url = "github:kleisli-io/nix-effects";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-filter = {
      url = "github:numtide/nix-filter";
    };
    namaka = {
      url = "github:nix-community/namaka";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-plugins = {
      url = "github:shlevy/nix-plugins";
      flake = false;
    };
    rnix-parser = {
      url = "github:nix-community/rnix-parser";
      flake = false;
    };
    claude-code-lsps = {
      url = "github:boostvolt/claude-code-lsps";
      flake = false;
    };
    attr-cmd = {
      url = "github:fricklerhandwerk/attr-cmd";
      flake = false;
    };
    nixpkgs-review = {
      url = "github:Mic92/nixpkgs-review";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  lair.dent = { };
}
