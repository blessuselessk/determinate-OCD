# nix-output-monitor

> Real-time build visualization for Nix — live dependency tree, progress tracking, and build timing.

Source: `github:maralorn/nix-output-monitor`

### Purpose

Enhances Nix build output with a live dependency tree showing which packages are building, their status, color-coded indicators, and estimated completion times from historical data.

### Syntax

```bash
# Pipe approach
nix-build |& nom
nix-build --log-format internal-json -v |& nom --json

# Drop-in replacement
nom build <args>
nom shell <args>
nom develop <args>

# Legacy compatibility
nom-build <args>
nom-shell <args>
```

### Installation

Available as `pkgs.nix-output-monitor` in nixpkgs.

### Use Cases

- **Long build monitoring**: visualize dependency graph progress
- **Build bottleneck identification**: see what's blocking completion
- **Download/upload tracking**: distributed build progress
