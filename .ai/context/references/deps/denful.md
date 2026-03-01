# denful

> Dendritic Nix modules, enough to fill a den. Reusable facets and shared utilities for den-based configurations.

Source: `github:vic/denful`

### Define a Facet for Niri Window Manager in Denful

Source: https://context7.com/vic/denful/llms.txt

This example defines a reusable 'facet' for the Niri window manager. It specifies contributions to the `flake` and `nixos` module classes, including flake inputs, cachix configuration, and NixOS module imports. It also demonstrates aspect composition by including the `anarchy` aspect.

```nix
# facets/niri.nix
{
  inputs,
  lib,
  ...
}:
{
  flake.aspects.niri = { aspects, ... }:
  {
    description = ''
      Niri: a scrollable-tiling WM (https://github.com/YaLTeR/niri)
      Configured via https://github.com/sodiboo/niri-flake.
    '';

    # Flake-level contributions: inputs and caches
    flake = {
      flake-file.inputs.niri-flake = {
        url = lib.mkDefault "github:sodiboo/niri-flake";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      flake-file.nixConfig = {
        extra-substituters = [ "https://niri.cachix.org" ];
        extra-trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
      };

      # Compose with other aspects
      flake.aspects.anarchy = {
        includes = [ aspects.niri ];
      };
    };

    # NixOS-level contributions
    nixos = {
      imports = [ inputs.niri-flake.nixosModules.niri ];
    };
  };
}

```

______________________________________________________________________

### Utilize Denful Library Functions in Configurations

Source: https://context7.com/vic/denful/llms.txt

This snippet illustrates how to use utility functions provided by `denful.lib` within your Nix configurations. It shows an example of using a built-in function `dup` and how to extend the library with custom functions like `triple` and `greet`.

```nix
# modules/example.nix
{
  denful,
  ...
}:
{
  # Use the built-in dup function
  config.someOption = denful.lib.dup 21;  # Returns 42

  # Extend the library with custom functions
  config.denful.lib = {
    triple = x: x * 3;
    greet = name: "Hello, ${name}!";
  };
}

```

### denful - Dendritic Nix modules, enough to fill a den.

Source: https://github.com/vic/denful/blob/main/README.md

Denful allows users to select individual modules using the `flake.modules.<class>.<name>` path. Beyond individual modules, Denful also provides higher-level modules called **facets**. These facets are analogous to layers in editor configurations like Spacemacs or plugin bundles in other software distributions, offering a more integrated set of functionalities.

______________________________________________________________________

### denful - Dendritic Nix modules, enough to fill a den. > Facets > `facet`s definition.

Source: https://github.com/vic/denful/blob/main/README.md

The definition of a facet in Denful is primarily intended for facet authors but is also valuable for users. Facets are structured using the syntax of [`flake.aspects`](https://github.com/vic/flake-aspects). Resolved modules within a facet become accessible via `flake.modules.<class>.niri` (using 'niri' as an example name), and users can also reference them directly as `flake.aspects.niri` if they are using it as an aspect dependency. The example provided demonstrates a facet structure, showing how it can define dependencies, configure Nix settings, and even enhance other aspects.

______________________________________________________________________

### denful - Dendritic Nix modules, enough to fill a den. > Facets > `facet` usage

Source: https://github.com/vic/denful/blob/main/README.md

To use a facet in your Dendritic module, you typically import it using `inputs.denful.modules.<class>.<name>`. For instance, if you want to include the 'niri' facet, you would use `imports = [ inputs.denful.modules.flake.niri ];`. Within your configuration, you can then define aspects that include the features provided by the facet. For example, an aspect named `my-laptop` could include all features contributing to the `anarchy` aspect by specifying `includes = [ aspects.anarchy ];`.
