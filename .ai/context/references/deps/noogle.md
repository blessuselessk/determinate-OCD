# noogle

> Nix API search engine — find Nix and nixpkgs lib functions by name or type signature.

Source: `github:nix-community/noogle` / https://noogle.dev

### Purpose

Web-based search engine for Nix functions. Wasm-powered, searches lib and builtins by keyword or type signature. Renders doc comments, covers undocumented functions including `builtins.derivation`. Daily-updated from nixpkgs main.

### Key Features

- Type signature filtering (search by function type)
- Function alias detection (lib ↔ builtins)
- Beginner-friendly search ranking
- Pre-rendered static HTML (indexable by search engines)
- Covers undocumented builtins

### Use Cases

- **Function discovery**: find lib functions by name or type
- **Learning Nix**: explore standard library interactively
- **Aspect authoring**: look up lib helpers when writing aspects
