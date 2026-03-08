# denix

> Nix library for scalable NixOS, Home Manager, and nix-darwin configurations with hosts and rices.

Source: `github:yunfachi/denix`

### Purpose

Unified configuration framework — write NixOS, Home Manager, and nix-darwin configs in a single file. Denix handles separation automatically. Supports hosts (machine-specific), rices (cross-machine customizations), and custom extensions.

### Setup

```bash
# Minimal template (recommended)
nix flake init -t github:yunfachi/denix#minimal

# Without rices
nix flake init -t github:yunfachi/denix#minimal-no-rices

# Extensions collection
nix flake init -t github:yunfachi/denix#extensions-collection
```

### Key Concepts

- **Hosts**: machine-specific settings (hostname, hardware, etc.)
- **Rices**: customizations applicable across all machines (themes, shell config)
- **Extensions**: reusable modules for adding functions and features
- **Unified files**: single-file configs that compile to NixOS + HM + darwin

### Use Cases

- **Multi-machine dotfiles**: manage configs for different hosts from one repo
- **Cross-platform configs**: target NixOS + macOS from the same source
- **Comparing with den**: alternative approach to the den framework we use
