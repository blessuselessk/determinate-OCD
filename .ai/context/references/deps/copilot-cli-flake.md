# copilot-cli-flake

> Nix flake packaging GitHub Copilot CLI for all platforms with weekly auto-updates.

Source: `github:scarisey/copilot-cli-flake`

### Purpose

Packages GitHub Copilot CLI for NixOS, nix-darwin, and Home Manager. Multi-arch (x86_64/aarch64, linux/darwin). Weekly automated version bumps.

### Syntax

```bash
# Quick test
nix develop github:scarisey/copilot-cli-flake
copilot --help

# Install via profile
nix profile install github:scarisey/copilot-cli-flake

# Usage
gh auth login              # authenticate first
copilot                    # interactive mode
copilot -p "your query"    # non-interactive
```

### Use Cases

- **Terminal AI assistance**: Copilot in the shell without GUI
- **Nix-managed install**: declarative Copilot CLI across machines
