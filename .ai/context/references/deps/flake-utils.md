# flake-utils

> Pure Nix flake utility functions for eliminating per-system boilerplate, independent of nixpkgs.

Source: <https://github.com/numtide/flake-utils>

## Purpose

flake-utils provides reusable helper functions for writing Nix flakes without external dependencies. It addresses the repetitive boilerplate of manually building hierarchical outputs per system and simplifies common patterns like multi-system package definitions, application exports, and flake composition.

## Setup / Syntax

Add to your `flake.nix` inputs:

```nix
inputs.flake-utils.url = "github:numtide/flake-utils";
```

To customize supported systems, override the `systems` input:

```nix
inputs.systems.url = "github:nix-systems/x86_64-linux";
inputs.flake-utils.inputs.systems.follows = "systems";
```

## Key Features / API

### `eachSystem :: [<system>] -> (<system> -> attrs) -> attrs`

Iterates over a list of systems and restructures outputs hierarchically:

```nix
eachSystem [ system.x86_64-linux ] (system: { hello = 42; })
# => { hello = { x86_64-linux = 42; } }
```

### `eachDefaultSystem :: (<system> -> attrs) -> attrs`

Convenience wrapper pre-populated with `defaultSystems` (`x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, `aarch64-darwin`):

```nix
outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    {
      packages = rec {
        hello = pkgs.hello;
        default = hello;
      };
      apps = rec {
        hello = flake-utils.lib.mkApp { drv = self.packages.${system}.hello; };
        default = hello;
      };
    }
  );
```

### `eachDefaultSystemPassThrough :: (<system> -> attrs) -> attrs`

Like `eachDefaultSystem` but omits automatic `${system}` key injection. Useful for outputs that are not per-system (e.g. `nixosConfigurations`).

### `mkApp { drv, name?, exePath? }`

Constructs a flake-compatible app structure from a derivation:

```nix
mkApp { drv = self.packages.${system}.hello; }
```

### `flattenTree :: attrs -> attrs`

Flattens nested attribute trees, respecting `recurseIntoAttrs`:

```nix
flattenTree { hello = pkgs.hello; gitAndTools = pkgs.gitAndTools; }
# => {
#   hello = «derivation»;
#   "gitAndTools/git" = «derivation»;
#   "gitAndTools/hub" = «derivation»;
# }
```

### `meld :: attrs -> [path] -> attrs`

Merges multiple subflakes sharing common inputs for multi-component flake organization.

### `simpleFlake :: attrs -> attrs`

High-level wrapper for typical projects:

```nix
outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.simpleFlake {
    inherit self nixpkgs;
    name = "simple-flake";
    overlay = ./overlay.nix;
    shell = ./shell.nix;
    # systems defaults to the standard four
  };
```

Accepts: `self`, `nixpkgs`, `name` (required); `config`, `overlay`, `preOverlays`, `shell`, `systems` (optional).

### Constants

- `system` -- attribute set mapping system names for IDE autocompletion.
- `allSystems` -- complete list of all nixpkgs-defined systems.
- `defaultSystems` -- `["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"]`.

## Use Cases

- **Multi-system packages**: Define packages once, generate outputs for all target architectures.
- **Standardized app exports**: Use `mkApp` for consistent app output structure.
- **Mixed outputs**: Combine `eachDefaultSystem` for per-system outputs with `eachDefaultSystemPassThrough` for host-specific configs:

  ```nix
  inputs.flake-utils.lib.eachDefaultSystem (system: { ... })
  // inputs.flake-utils.lib.eachDefaultSystemPassThrough (system: {
    homeConfigurations."<NAME>" = /* ... */;
    nixosConfigurations."<NAME>" = /* ... */;
  })
  ```

- **Subflake composition**: Use `meld` to decompose large flakes into manageable subcomponents.
- **Development shells**: Create dev shells targeting multiple platforms with minimal boilerplate.
