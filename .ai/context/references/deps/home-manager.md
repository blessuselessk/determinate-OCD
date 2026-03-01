# home-manager

> Declarative management of user home environments using the Nix module system. Programs, dotfiles, packages, and services per-user.

Source: `github:nix-community/home-manager`

### Nix - Basic Home Environment Configuration

Source: https://context7.com/nix-community/home-manager/llms.txt

This Nix code defines the basic setup for a user's home environment using Home Manager. It specifies the username, home directory, and state version. It also lists packages to install, defines session environment variables, sets up shell aliases, configures additional PATH entries, and sets keyboard and locale preferences. Finally, it enables Home Manager's self-management.

```nix
# home.nix
{
  config,
  lib,
  pkgs,
  ... 
}:{

  # Required: user identity and state version
  home.username = "alice";
  home.homeDirectory = "/home/alice";
  home.stateVersion = "26.05";

  # Install packages
  home.packages = with pkgs;
    [
      ripgrep
      fd
      bat
      eza
      htop
      jq
    ];

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    PAGER = "less -R";
    VISUAL = "nvim";
  };

  # Shell aliases
  home.shellAliases = {
    ll = "ls -lah";
    ".." = "cd ..";
    g = "git";
  };

  # Additional PATH entries
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
  ];

  # Keyboard configuration
  home.keyboard = {
    layout = "us";
    options = [ "ctrl:nocaps" ];
  };

  # Locale settings
  home.language = {
    base = "en_US.UTF-8";
    time = "en_GB.UTF-8";
  };

  # Enable Home Manager self-management
  programs.home-manager.enable = true;
}

```

______________________________________________________________________

### Integrate Home Manager with NixOS System Configuration

Source: https://context7.com/nix-community/home-manager/llms.txt

This Nix code demonstrates how to integrate Home Manager into a NixOS system configuration. It sets global Home Manager options like `useGlobalPkgs`, `useUserPackages`, and `verbose`. It also shows how to import shared modules and define per-user configurations for applications like Git and Fish. Dependencies include NixOS and Home Manager modules. It enables system-wide management of user environments.

```nix
# configuration.nix
{
  config, pkgs, ... }:

{
  imports = [
    <home-manager/nixos>
  ];

  # Global Home Manager settings
  home-manager = {
    # Use system packages instead of separate store paths
    useGlobalPkgs = true;

    # Install packages to /etc/profiles instead of ~/.nix-profile
    useUserPackages = true;

    # Backup extension for conflicting files
    backupFileExtension = "backup";

    # Enable verbose output
    verbose = true;

    # Modules shared across all users
    sharedModules = [
      ./common-config.nix
    ];

    # Extra arguments passed to all home configurations
    extraSpecialArgs = {
      inherit myCustomValue;
    };

    # Per-user configurations
    users.alice = { pkgs, ... }: {
      home.stateVersion = "26.05";

      programs.git = {
        enable = true;
        userName = "Alice";
        userEmail = "alice@example.com";
      };

      home.packages = with pkgs; [
        neovim
        tmux
      ];
    };

    users.bob = { pkgs, ... }: {
      home.stateVersion = "26.05";

      programs.fish.enable = true;
    };
  };
}

```

______________________________________________________________________

### Nix - Configure Home Manager with Flake

Source: https://context7.com/nix-community/home-manager/llms.txt

This snippet demonstrates how to set up Home Manager using a Nix flake. It defines inputs for nixpkgs and home-manager, specifies the system architecture, and configures the 'alice' user's home environment using the `homeManagerConfiguration` function. It also shows how to pass custom arguments to modules.

```nix
# flake.nix
{
  description = "My home configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."alice" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = {
          myCustomArg = "value";
        };
      };
    };
}

```

______________________________________________________________________

### Declarative Home Manager Installation (Nix)

Source: https://github.com/nix-community/home-manager/blob/master/docs/manual/installation/nixos.md

Demonstrates a declarative approach to installing Home Manager by fetching the tarball and importing the NixOS module within configuration.nix. It also shows how to configure a user's environment, including packages and program settings.

```nix
{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz;
in
{
  imports =
    [
      (import "${home-manager}/nixos")
    ];

  users.users.eve.isNormalUser = true;
  home-manager.users.eve = { pkgs, ... }: {
    home.packages = [ pkgs.atool pkgs.httpie ];
    programs.bash.enable = true;

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "25.11";
  };
}
```

### Home Manager using Nix

Source: https://github.com/nix-community/home-manager/blob/master/README.md

Home Manager provides a basic system for managing a user's environment using the Nix package manager and Nixpkgs. It enables declarative configuration of user-specific packages and dotfiles, offering a robust way to maintain consistency across development environments.
