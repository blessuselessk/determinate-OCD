# patsh

> CLI that patches shell scripts to resolve command references to Nix store paths — like patchelf for scripts.

Source: `github:nix-community/patsh`

### Purpose

Automatically resolves and patches command references in shell scripts so they point to Nix store paths. Inspired by resholve. Written in Rust.

### Syntax

```bash
patsh <INPUT> [OUTPUT]          # patch script, write to output
patsh -f <INPUT>                # in-place patch
patsh -p /nix/store/... <INPUT> # custom PATH for resolution
patsh -s /nix/store <INPUT>     # custom store dir
patsh -b bash <INPUT>           # specify bash for builtin listing
```

### Key Features

- Resolves commands to Nix store paths automatically
- In-place patching with `--force`
- Custom PATH and store directory support
- Rust implementation

### Limitations

- ANSI-C quoting support incomplete
- Variable resolution partial
- No diagnostics for unresolved commands yet

### Use Cases

- **Reproducible scripts**: ensure scripts find correct executables in Nix builds
- **Packaging**: patch upstream scripts during derivation builds
- **Containerized environments**: resolve dependencies without relying on global PATH
