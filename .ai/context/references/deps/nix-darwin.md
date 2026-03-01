# nix-darwin

> Declarative macOS system configuration using the Nix module system. NixOS-style management for macOS.

Source: `github:nix-darwin/nix-darwin`

### Define macOS System Configuration with nix-darwin (Nix)

Source: https://context7.com/nix-darwin/nix-darwin/llms.txt

The `darwinSystem` function is the primary entry point for defining a nix-darwin configuration. It takes a list of modules to create a complete system evaluation. This example demonstrates a basic flake setup defining a system named 'MacBook-Pro'.

```nix
# flake.nix
{
  description = "My macOS system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nix-darwin, nixpkgs }:
    {
      darwinConfigurations."MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          ./configuration.nix
          ({ pkgs, ... }: {
            environment.systemPackages = [ pkgs.git pkgs.vim pkgs.htop ];
            services.nix-daemon.enable = true;
            system.stateVersion = 6;
            nixpkgs.hostPlatform = "aarch64-darwin";
          })
        ];
        specialArgs = { inherit self; };
      };
    };
}

```

______________________________________________________________________

### darwinSystem - Build a nix-darwin configuration

Source: https://context7.com/nix-darwin/nix-darwin/llms.txt

Creates a complete system configuration from a set of modules, returning an evaluation containing all system settings and the build closure. This is the primary entry point for defining macOS systems declaratively.

````APIDOC
## darwinSystem - Build a nix-darwin configuration

### Description
Creates a complete system configuration from a set of modules, returning an evaluation containing all system settings and the build closure. This is the primary entry point for defining macOS systems declaratively.

### Method
N/A (Nix function)

### Endpoint
N/A (Nix function)

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
None

### Request Example
```nix
# flake.nix
{
  description = "My macOS system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nix-darwin, nixpkgs }:
    {             
      darwinConfigurations."MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          ./configuration.nix
          ({ pkgs, ... }:
            {
              environment.systemPackages = [ pkgs.git pkgs.vim pkgs.htop ];
              services.nix-daemon.enable = true;
              system.stateVersion = 6;
              nixpkgs.hostPlatform = "aarch64-darwin";
            })
        ];
        specialArgs = { inherit self; };
      };
    };
}
````

### Response

#### Success Response (200)

N/A (Nix evaluation output)

#### Response Example

N/A

````

--------------------------------

### darwin-rebuild - Apply system configuration changes

Source: https://context7.com/nix-darwin/nix-darwin/llms.txt

Command-line tool for building and activating nix-darwin configurations, similar to nixos-rebuild on NixOS systems.

```APIDOC
## darwin-rebuild - Apply system configuration changes

### Description
Command-line tool for building and activating nix-darwin configurations, similar to nixos-rebuild on NixOS systems.

### Method
CLI command

### Endpoint
N/A (CLI command)

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
None

### Request Example
```bash
# Initial installation (flakes)
sudo nix run nix-darwin/master#darwin-rebuild -- switch

# Apply configuration changes after editing
sudo darwin-rebuild switch

# Build without activating
sudo darwin-rebuild build

# Check configuration without applying
sudo darwin-rebuild check

# View changelog between generations
sudo darwin-rebuild changelog

# Use specific flake configuration
sudo darwin-rebuild switch --flake .#MacBook-Pro

# Build with local nix-darwin changes
sudo darwin-rebuild switch -I darwin=.

# Rollback to previous generation
sudo darwin-rebuild rollback

# List all generations
sudo darwin-rebuild --list-generations
````

### Response

#### Success Response (200)

N/A (CLI output)

#### Response Example

N/A

````

--------------------------------

### Apply nix-darwin System Configuration Changes (Bash)

Source: https://context7.com/nix-darwin/nix-darwin/llms.txt

The `darwin-rebuild` command-line tool is used to build, switch, and manage nix-darwin system configurations. It mirrors the functionality of `nixos-rebuild` for NixOS. This snippet shows common commands for applying, building, checking, and rolling back configurations.

```bash
# Initial installation (flakes)
sudo nix run nix-darwin/master#darwin-rebuild -- switch

# Apply configuration changes after editing
sudo darwin-rebuild switch

# Build without activating
sudo darwin-rebuild build

# Check configuration without applying
sudo darwin-rebuild check

# View changelog between generations
sudo darwin-rebuild changelog

# Use specific flake configuration
sudo darwin-rebuild switch --flake .#MacBook-Pro

# Build with local nix-darwin changes
sudo darwin-rebuild switch -I darwin=.

# Rollback to previous generation
sudo darwin-rebuild rollback

# List all generations
sudo darwin-rebuild --list-generations

````

### nix-darwin

Source: https://context7.com/nix-darwin/nix-darwin/llms.txt

The framework extends Nixpkgs with macOS-specific modules for managing system settings, services, applications, and user environments. It integrates seamlessly with Homebrew, manages launchd services, configures system defaults, and provides a declarative interface for nearly every aspect of macOS configuration. nix-darwin supports both flake-based and channel-based setups, with flakes being the recommended approach for new users despite being an experimental Nix feature.
