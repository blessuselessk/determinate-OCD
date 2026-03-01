# flake-aspects

> A flake-parts module that transposes flake.aspects into flake.modules for intuitive dendritic configuration with cross-aspect dependency management.

Source: `github:vic/flake-aspects`

### Nix flake.nix Quick Start with flake-aspects

Source: https://github.com/vic/flake-aspects/blob/main/README.md

Demonstrates how to integrate the flake-aspects module into a flake.nix file to utilize the transposed module structure. It shows the basic setup for importing the flake-aspects module and defining aspects within the flake configuration.

```nix
# flake.nix
{
  inputs.flake-aspects.url = "github:vic/flake-aspects";
  outputs = { flake-parts, flake-aspects, nixpkgs, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ flake-aspects.flakeModule ];
      flake.aspects = { aspects, ... }: {
        my-desktop = {
          nixos  = { };
          darwin = { };
          includes = [ aspects.my-tools ];
        };
        my-tools.nixos = { };
      };
    };
}

```

______________________________________________________________________

### flake-parts Integration with flakeModule

Source: https://context7.com/vic/flake-aspects/llms.txt

The `flakeModule` function integrates flake-aspects with flake-parts, automatically generating transposed and resolved modules from defined aspects. This is the recommended approach for flake-based projects. It allows defining aspects with configurations for multiple classes (nixos, darwin, homeManager) and managing dependencies between aspects.

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-aspects.url = "github:vic/flake-aspects";
  };

  outputs = { self, nixpkgs, flake-parts, flake-aspects, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ flake-aspects.flakeModule ];

      flake.aspects = { aspects, ... }: {
        # Define aspects with multiple class configurations
        my-desktop = {
          nixos = { pkgs, ... }: {
            environment.systemPackages = [ pkgs.firefox pkgs.vscode ];
            services.xserver.enable = true;
          };
          darwin = { pkgs, ... }: {
            environment.systemPackages = [ pkgs.firefox ];
            services.yabai.enable = true;
          };
          homeManager = { pkgs, ... }: {
            programs.git.enable = true;
          };
        };

        # Aspect with dependencies
        my-server = {
          includes = [ aspects.base-tools ];
          nixos = { services.nginx.enable = true; };
        };

        base-tools.nixos = { pkgs, ... }: {
          environment.systemPackages = with pkgs; [ git curl wget ];
        };
      };

      # Use resolved modules in configurations
      flake.nixosConfigurations.workstation = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.modules.nixos.my-desktop  # Fully resolved module
        ];
      };
    };
}

```

______________________________________________________________________

### Aspects Functionality - Nix

Source: https://github.com/vic/flake-aspects/blob/main/docs/src/content/docs/reference/api.mdx

Provides aspect-aware transposition. It supplies a custom `emit` function to the `transpose` function, which in turn calls `resolve` on each item. The output is a `transposed` set containing resolved modules keyed by `<class>.<aspect>`.

```nix
aspects : lib → aspectsConfig → { transposed }

# Aspect-aware transposition. Supplies a custom `emit` to `transpose` that calls `resolve` on each item.
# Returns { transposed = { <class>.<aspect> = resolved-module; }; }
```

______________________________________________________________________

### aspects Function

Source: https://github.com/vic/flake-aspects/blob/main/docs/src/content/docs/reference/api.mdx

Performs aspect-aware transposition by supplying a custom `emit` to `transpose` that calls `resolve` on each item. Returns `{ transposed = { <class>.<aspect> = resolved-module; }; }`.

```APIDOC
## aspects

### Description

Aspect-aware transposition. Supplies a custom `emit` to `transpose` that calls `resolve` on each item. Returns `{ transposed = { <class>.<aspect> = resolved-module; }; }`.

### Method

N/A (Function export)

### Endpoint

N/A

### Parameters

#### Path Parameters

- **lib** (object) - The Nix library object.
- **aspectsConfig** (object) - Configuration for aspects.

### Request Example

N/A

### Response

#### Success Response (200)

- **transposed** (object) - An object where keys are `<class>.<aspect>` and values are resolved modules.

#### Response Example

N/A
```

### flake-aspects

Source: https://github.com/vic/flake-aspects/blob/main/docs/src/content/docs/index.mdx

**flake-aspects** is a small, dependency-free Nix library that transposes `<aspect>.<class>` into `<class>.<aspect>` — the standard `flake.modules` layout.

On top of transposition, it provides a composable dependency graph via `includes`, nestable sub-aspects via `provides` (alias `_`), parametric curried providers, context-aware `__functor` override, and cross-class `forward`.
