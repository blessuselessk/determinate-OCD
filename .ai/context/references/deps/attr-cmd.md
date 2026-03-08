# attr-cmd

> Nix library that transforms nested attribute sets into executable shell commands, enabling declarative CLI construction from hierarchical Nix structures.

Source: `github:fricklerhandwerk/attr-cmd`

## Purpose

attr-cmd maps Nix attribute set hierarchies to shell command trees. Each derivation leaf in a nested attrset becomes a subcommand, with the attribute path forming the command structure. This lets you build sophisticated CLIs declaratively, where intermediate nodes provide help text and leaf nodes execute programs.

______________________________________________________________________

### Key API -- `lib.attr-cmd.exec`

Source: https://github.com/fricklerhandwerk/attr-cmd

**Type:** `exec :: AttrSet -> AttrSet`

The `exec` function accepts a nested attribute set and produces a flat attribute set of executables. For each attribute path containing a derivation, it extracts the root-level name and creates a corresponding `/bin/<name>` executable.

**Behavior:**
- Scans input attributes at any depth
- Identifies leaves that are derivations
- Creates top-level executables for each derivation found
- Ignores non-derivation attributes
- Intermediate subcommands display help using `meta.description`

**Invocation pattern:**
```
<root> ... <attr> [<arguments>]...
```

______________________________________________________________________

### Complete Example

Source: https://github.com/fricklerhandwerk/attr-cmd

```nix
# ./default.nix
{
  sources ? import ./npins,
  system ? builtins.currentSystem,
  pkgs ? import sources.nixpkgs {
    inherit system;
    config = { };
    overlays = [ ];
  },
  attr-cmd ? pkgs.callPackage "${sources.attr-cmd}/lib.nix" {},
}:
let
  lib = pkgs.lib // attr-cmd.lib;
in
rec {
  foo.bar.baz = pkgs.writeScriptBin "baz" "echo success $@";

  commands = lib.attr-cmd.exec { inherit foo; };

  shell = pkgs.mkShellNoCC {
    packages = builtins.attrValues commands ++ [
      pkgs.npins
    ];
  };
}
```

**Usage:**

```console
$ nix-shell -p npins --run "npins init"
$ nix-shell

[nix-shell:~]$ foo bar baz
success

[nix-shell:~]$ foo bar baz or else
success or else
```

The nested attribute path `foo.bar.baz` becomes the command `foo bar baz`. Arguments after the final subcommand are passed through to the derivation's program.

______________________________________________________________________

### Integration with pkgs

Source: https://github.com/fricklerhandwerk/attr-cmd

Load the library by calling `lib.nix` from the attr-cmd source:

```nix
attr-cmd = pkgs.callPackage "${sources.attr-cmd}/lib.nix" {};
lib = pkgs.lib // attr-cmd.lib;
```

The `lib.attr-cmd.exec` function is then available for use. Output derivations can be added to dev shells, packages, or any Nix environment.

______________________________________________________________________

### Help Text via meta.description

Source: https://github.com/fricklerhandwerk/attr-cmd

Intermediate subcommands display help text when `meta.description` is set on derivations. Running a partial command (e.g., `foo bar` without `baz`) shows available subcommands and their descriptions:

```nix
{
  foo.bar.baz = pkgs.writeScriptBin "baz" "echo success $@" // {
    meta.description = "Run the baz operation";
  };
  foo.bar.qux = pkgs.writeScriptBin "qux" "echo other $@" // {
    meta.description = "Run the qux operation";
  };
}
```

______________________________________________________________________

## Use Cases

- **Project automation**: Organize build, test, deploy scripts as subcommand trees
- **Dev environments**: Expose project-specific tooling via `mkShell` with structured commands
- **CLI wrappers**: Create user-friendly interfaces over complex toolchains
- **Monorepo tooling**: Namespace commands per package or component using attribute nesting
