# nh

> Modern Nix CLI helper — cohesive interface for NixOS, Home Manager, and nix-darwin with build visualization.

Source: `github:nix-community/nh`

### Purpose

Rust-based tool that consolidates and reimplements Nix ecosystem commands with better ergonomics. Provides build-tree visualization (via nix-output-monitor), pretty diffs, and confirmation prompts.

### Syntax

```bash
# NixOS
nh os switch .              # rebuild and switch
nh os switch . -H myHost    # specify host

# Home Manager
nh home switch . -c myHome

# nix-darwin
nh darwin switch .

# Search
nh search <query>           # fast Elasticsearch-powered search

# Clean
nh clean all --keep 5       # GC with retention
nh clean all --keep-since 7d
```

### Key Commands

| Command | Purpose |
|---------|---------|
| `nh os` | NixOS system management (replaces nixos-rebuild) |
| `nh home` | Home Manager config management |
| `nh darwin` | nix-darwin system management |
| `nh search` | Fast package search |
| `nh clean` | Enhanced garbage collection with gcroot cleanup |

### Use Cases

- **Build + activate with feedback**: visual build tree and diff before switch
- **Cross-platform management**: NixOS, darwin, HM from one tool
- **Safe GC**: time-based retention policies
