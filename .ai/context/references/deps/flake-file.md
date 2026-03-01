# flake-file

> Generates clean, maintainable flake.nix from Nix module options. Declare inputs where you use them.

Source: `github:vic/flake-file`

### Declare flake inputs in Nix modules

Source: https://context7.com/vic/flake-file/llms.txt

Defines flake inputs using the `flake-file.inputs` option within Nix modules. Supports various input types including basic GitHub, overridden defaults, followed inputs, non-flake inputs, and typed references. Requires the flake-file Nix tool.

```nix
# modules/inputs.nix
{ lib, ... }:
{
  flake-file = {
    description = "My awesome flake";

    inputs = {
      # Basic GitHub input
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

      # Input with mkDefault (can be overridden by other modules)
      flake-parts.url = lib.mkDefault "github:hercules-ci/flake-parts";

      # Follow another input
      nixpkgs-lib.follows = "nixpkgs";

      # Non-flake input
      my-tool = {
        url = "github:owner/my-tool";
        flake = false;
      };

      # Input with nested follows
      some-dep = {
        url = "github:owner/some-dep";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      # Typed reference with specific attributes
      my-repo = {
        type = "github";
        owner = "myorg";
        repo = "myrepo";
        ref = "develop";
      };

      # Git input with submodules
      private-repo = {
        type = "git";
        url = "ssh://git@github.com/org/repo.git";
        submodules = true;
      };
    };
  };
}
```

______________________________________________________________________

### Daily flake-file commands

Source: https://github.com/vic/flake-file/blob/main/docs/src/content/docs/tutorials/migrate-flake-parts.mdx

Provides essential commands for managing a flake-file enabled flake, including regenerating `flake.nix` and checking flake integrity.

```shell
nix run .#write-flake # whenever you need to regen flake.nix

nix flake check # will make sure your flake.nix is up-to-date
```

______________________________________________________________________

### Daily Workflow Commands for flake-file Projects

Source: https://context7.com/vic/flake-file/llms.txt

These shell commands outline the typical daily workflow for managing a flake-file project. They include regenerating the flake.nix, checking for synchronization, and updating lock files.

```shell
# Daily workflow commands
nix run .#write-flake    # Regenerate flake.nix after changing inputs
nix flake check          # Verify flake.nix is in sync (use in CI)
nix flake update         # Update lock file
```

### How it Works > The Option Schema

Source: https://github.com/vic/flake-file/blob/main/docs/src/content/docs/explanation/how-it-works.mdx

Options mirror the flake schema and extend it further. The `flake-file.description` is for the flake description string. `flake-file.nixConfig` is for Nix binary cache and substituter config. `flake-file.inputs.<name>.*` are for input declarations like url, follows, flake, ref, etc. `flake-file.outputs` is for the literal Nix expression for the outputs function. `flake-file.write-hooks` are commands run after writing, and `flake-file.check-hooks` are commands run during check. `flake-file.prune-lock.*` is for automatic lock flattening.

______________________________________________________________________

### flake-file

Source: https://context7.com/vic/flake-file/llms.txt

The tool integrates with the Nix module system, allowing inputs to be declared in any module close to where they're used. Multiple modules can contribute to the same input set, with `lib.mkDefault` and `lib.mkForce` working as expected. flake-file supports multiple backends: Nix flakes (`flake.nix`), unflake, npins, and nixlock—all from the same module definitions. A built-in flake check ensures generated files stay in sync with module declarations.
