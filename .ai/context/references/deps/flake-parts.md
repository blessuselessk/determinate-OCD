# flake-parts

> Core of a distributed framework for writing Nix Flakes. Provides the options that represent standard flake attributes and establishes a way of working with `system`. Opinionated features are provided by an ecosystem of modules that you can import.

Source: `github:hercules-ci/flake-parts`

## Purpose

flake-parts is a lightweight module framework for Nix Flakes. It mirrors the Nix flake schema minimally, enabling developers to split `flake.nix` into focused, reusable modules. Unlike NixOS's monorepo approach, flake-parts is a single foundational module that other repositories can extend, encouraging ecosystem-based development.

Key benefits:
- Split `flake.nix` into focused units, each in their own file
- Abstract away system-specific complexity via `perSystem`
- Allow library flakes to provide composable outputs
- Reuse project logic written by others through flakeModules

______________________________________________________________________

### mkFlake -- Entry Point

Source: https://github.com/hercules-ci/flake-parts

The central API function. Wraps your flake outputs in the module system. Accepts `inputs` and a module body.

```nix
{
  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        # Put your original flake attributes here.
      };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    };
}
```

______________________________________________________________________

### Initializing a New Project

Source: https://github.com/hercules-ci/flake-parts

```console
nix flake init -t github:hercules-ci/flake-parts
```

For existing flakes, add the input and wrap outputs with `mkFlake`:

```nix
flake-parts.url = "github:hercules-ci/flake-parts";
```

______________________________________________________________________

### perSystem -- System-Scoped Outputs

Source: https://flake.parts/options/flake-parts.html

The `perSystem` module attribute defines system-specific outputs. The framework automatically iterates across all declared `systems`, eliminating boilerplate. Available sub-options:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `packages` | lazy attrset of packages | `{ }` | Packages output |
| `apps` | lazy attrset of submodules | `{ }` | Apps output (each has `program` and `type`) |
| `checks` | lazy attrset of packages | `{ }` | Flake checks |
| `devShells` | lazy attrset of packages | `{ }` | Development shells |
| `formatter` | null or package | `null` | Formatter package |
| `legacyPackages` | lazy attrset | `{ }` | Legacy packages output |
| `bundlers` | lazy attrset of functions | `{ }` | Bundler functions |

```nix
{
  perSystem = { pkgs, ... }: {
    packages.default = pkgs.hello;
    devShells.default = pkgs.mkShell {
      packages = [ pkgs.nixfmt ];
    };
    formatter = pkgs.nixfmt;
  };
}
```

______________________________________________________________________

### flake -- Raw Flake Attributes

Source: https://flake.parts/options/flake-parts.html

The `flake` option holds raw flake output attributes that are not system-scoped. This is where you put `nixosConfigurations`, `nixosModules`, `overlays`, `flakeModules`, and other top-level outputs.

```nix
{
  flake = {
    nixosConfigurations.myhost = ...;
    nixosModules.default = ...;
    overlays.default = final: prev: { ... };
  };
}
```

______________________________________________________________________

### systems -- Target Architectures

Source: https://flake.parts/options/flake-parts.html

A list of system strings that `perSystem` iterates over. All `perSystem` outputs are generated for each system in this list.

```nix
{
  systems = [ "x86_64-linux" "aarch64-darwin" ];
}
```

______________________________________________________________________

### flakeModules -- Reusable Module Bundles

Source: https://flake.parts/options/flake-parts.html

Expose reusable flake-parts modules for other flakes to import. Consumers use `imports = [ inputs.your-flake.flakeModules.default ];`.

```nix
{
  flake.flakeModules.default = {
    imports = [ ./my-module.nix ];
  };
}
```

______________________________________________________________________

### transposition -- Lifting perSystem to Flake Outputs

Source: https://flake.parts/options/flake-parts.html

Transposes attributes between `perSystem` and top-level flake outputs. The `adHoc` option provides a stub option declaration for custom attributes.

```nix
{
  transposition.<name>.adHoc = true;
}
```

______________________________________________________________________

### partitions -- Isolated Module Evaluations

Source: https://flake.parts/options/flake-parts.html

Partitions allow distinct module system evaluations with different inputs for different flake attributes. This avoids fetching unnecessary inputs for unrelated outputs.

```nix
{
  partitionedAttrs.devShells = "dev";
  partitions.dev = {
    extraInputsFlake = ./dev/flake.nix;
    module = { imports = [ ./dev/module.nix ]; };
  };
}
```

______________________________________________________________________

### debug -- REPL Inspection

Source: https://flake.parts/options/flake-parts.html

When `debug = true`, adds `debug`, `allSystems`, and `currentSystem` attributes to flake output for inspection in `nix repl`.

```nix
{
  debug = true;
}
```

______________________________________________________________________

### Module Arguments in perSystem

Source: https://flake.parts/options/flake-parts.html

Inside `perSystem`, these module arguments are available:

| Argument | Description |
|----------|-------------|
| `pkgs` | nixpkgs for the current system (if nixpkgs input exists) |
| `system` | Current system string |
| `inputs'` | Inputs with system pre-applied |
| `self'` | Self outputs with system pre-applied |
| `config` | The perSystem config |
| `lib` | nixpkgs lib |

______________________________________________________________________

## Use Cases

- **Multi-system flakes**: Define outputs once, generate for all architectures
- **Modular project configs**: Split CI, dev tools, packages into separate files
- **Library flakes**: Expose `flakeModules` for consumers to compose
- **Large monorepos**: Use `partitions` to avoid fetching dev-only inputs in CI
