# nixtract

> CLI tool that extracts the full derivation dependency graph from a Nix flake as structured JSONL.

Source: `github:tweag/nixtract`

### Purpose

Nixtract recursively discovers all derivations within a Nix flake and their dependency relationships, outputting structured data (name, version, license, deps) for each.

### Installation

```bash
nix shell github:tweag/nixtract
```

### CLI Syntax

```bash
# Extract from current flake (default: nixpkgs)
nixtract

# Write to file
nixtract derivations.jsonl

# Target a specific flake
nixtract -f github:nixos/nixpkgs/23.05

# Extract a specific attribute path
nixtract -a haskellPackages.hello

# Target a specific system
nixtract -s x86_64-darwin

# Pretty-print JSON output
nixtract --pretty

# Show the output schema
nixtract --output-schema
```

### Output Format

JSONL (one JSON object per line) — each line represents one derivation with metadata: name, version, license, and dependency edges.

### Use Cases

- **Dependency auditing**: trace transitive deps of any flake output
- **License scanning**: enumerate licenses across the full build closure
- **Aspect analysis**: map which derivations an aspect pulls in, identify bloat
- **Graph visualization**: pipe JSONL into tools like `jq` + `graphviz` to render dep trees
