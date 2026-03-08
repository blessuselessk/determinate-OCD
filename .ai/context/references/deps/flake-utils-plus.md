# flake-utils-plus

> Nix library for painless NixOS flake configuration with multi-channel support, host management, and overlay composition.

Source: <https://github.com/gytis-ivaskevicius/flake-utils-plus>

## Purpose

flake-utils-plus builds on top of flake-utils to provide a higher-level abstraction for generating NixOS flake configurations. It reduces the boilerplate and complexity of managing multiple nixpkgs channels, host configurations, overlays, and system builders -- offering a simpler alternative to heavier frameworks like DevOS.

## Setup / Syntax

Add to your flake inputs and use `mkFlake` as the primary entry point:

```nix
{
  inputs.flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";

  outputs = { self, nixpkgs, flake-utils-plus, ... }@inputs:
    flake-utils-plus.lib.mkFlake {
      inherit self inputs;
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      # ... channels, hosts, outputsBuilder
    };
}
```

## Key Features / API

### Channel Management

Define multiple nixpkgs channels with independent configs, overlays, and patches:

```nix
channelsConfig = { allowBroken = true; };  # shared across all channels
sharedOverlays = [ nur.overlay ];           # overlays applied to all channels

channels.nixpkgs.input = nixpkgs;
channels.nixpkgs.config = { allowUnfree = true; };

channels.unstable.input = nixpkgs-unstable;
channels.unstable.patches = [ ./someAwesomePatch.patch ];
channels.unstable.overlaysBuilder = channels: [
  (final: prev: { inherit (channels.nixpkgs) some-stable-pkg; })
];
```

### Host Configuration

Define NixOS (or Darwin) hosts with shared defaults and per-host overrides:

```nix
hostDefaults.system = "x86_64-linux";
hostDefaults.channelName = "nixpkgs";
hostDefaults.modules = [ ./common.nix ];
hostDefaults.extraArgs = { inherit utils inputs; };

hosts.myhost.system = "aarch64-linux";
hosts.myhost.channelName = "unstable";
hosts.myhost.modules = [ ./configuration.nix ];
hosts.myhost.extraArgs = { abc = 123; };
hosts.myhost.specialArgs = { thing = "abc"; };  # usable in imports without infinite recursion

# For non-NixOS targets:
hosts.mymac.output = "darwinConfigurations";
hosts.mymac.builder = darwin.lib.darwinSystem;
```

### `outputsBuilder`

Receives all instantiated channels and returns per-system flake outputs:

```nix
outputsBuilder = channels: {
  packages = { inherit (channels.unstable) package-from-overlays; };
  apps.custom-neovim = mkApp {
    drv = fancy-neovim;
    exePath = "/bin/nvim";
  };
  defaultPackage = channels.nixpkgs.neovim;
  devShell = channels.nixpkgs.mkShell { name = "devShell"; };
};
```

### Library Functions

- **`lib.exportModules [ ./a.nix ./b.nix ]`** -- generates `{ a = import ./a.nix; b = import ./b.nix; }`.
- **`lib.exportOverlays channels`** -- exports channel overlays as namespaced attributes for external consumption.
- **`lib.exportPackages self.overlays channels`** -- exports overlays as platform-specific packages (cacheable across flakes, unlike raw overlays).
- **`pkgs.fup-repl`** -- interactive REPL utility; `repl` loads system nixpkgs, `repl /path/to/flake.nix` loads a specific flake.

### NixOS Module Options

These options are available in NixOS configurations built by flake-utils-plus:

- **`nix.generateRegistryFromInputs`** -- auto-generates `nix.registry` from flake inputs.
- **`nix.generateNixPathFromInputs`** -- auto-generates `nix.nixPath` from available inputs.
- **`nix.linkInputs`** -- symlinks inputs to `/etc/nix/inputs`.

## Use Cases

- **Multi-channel NixOS deployments**: Run stable and unstable nixpkgs side by side, cherry-picking packages across channels via `overlaysBuilder`.
- **Mixed NixOS + Darwin fleets**: Use `output` and `builder` per host to target both `nixosConfigurations` and `darwinConfigurations` from a single flake.
- **Overlay distribution**: Use `exportPackages` to make overlay-provided packages cacheable and consumable by downstream flakes.
- **Development environments**: Define per-system `devShell` outputs through `outputsBuilder` with access to all channel package sets.
- **Registry/path alignment**: Keep `nix.registry` and `nix.nixPath` in sync with flake inputs automatically.
