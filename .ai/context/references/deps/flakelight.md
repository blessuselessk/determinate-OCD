# flakelight

> Modular Nix flake framework that minimizes boilerplate while supporting all flake output types.

Source: `github:nix-community/flakelight`

### Purpose

Flakelight auto-generates per-system attributes, packages, overlays, devShells, and formatters from minimal declarations. Directory-based autoloading (default `./nix`) discovers modules automatically.

### Basic Syntax

```nix
{
  inputs.flakelight.url = "github:nix-community/flakelight";
  outputs = { flakelight, ... }:
    flakelight ./. {
      # devShell with packages
      devShell.packages = pkgs: [ pkgs.hello pkgs.coreutils ];

      # package from default.nix
      package = { stdenv }: stdenv.mkDerivation { ... };

      # overlay
      overlays.default = final: prev: { ... };
    };
}
```

### Language-Specific Modules

```nix
# Rust project — auto-detects from Cargo.toml
{
  inputs.flakelight-rust.url = "github:accelbread/flakelight-rust";
  outputs = { flakelight-rust, ... }: flakelight-rust ./. { };
}
```

Community modules exist for Rust, Zig, Haskell, and more.

### Key Features

- Per-system attribute generation across platforms
- Directory-based autoloading of `.nix` files
- Package definitions auto-generate overlays
- Module system for sharing common configs
- Extensible via `flakelight.url` modules

### Use Cases

- **Studying flake patterns**: reference for how to structure flake outputs
- **Quick prototyping**: minimal flake for testing packages or devShells
- **Module extraction**: understand how to decompose flake logic into composable units
- **Cross-project comparison**: compare flakelight's approach with den/flake-parts
