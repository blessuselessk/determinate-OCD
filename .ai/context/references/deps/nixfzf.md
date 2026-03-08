# nixfzf

> Fuzzy-find CLI for searching nixpkgs packages, NixOS options, and home-manager options.

Source: `github:strikerlulu/nixfzf`

### Purpose

Shell script that uses fzf to interactively search and browse nixpkgs packages, NixOS configuration options, and home-manager options with preview support.

### Syntax

```bash
nixfzf           # search nixpkgs (default)
nixfzf -n        # search nixpkgs
nixfzf -o        # browse NixOS options
nixfzf -m        # browse home-manager options
nixfzf -u -n     # update nixpkgs cache
nixfzf -u -o     # update NixOS options cache
nixfzf -h        # help
```

### Requirements

- fzf
- `yq` or `gojq` for option previews

### Use Cases

- **Package discovery**: fuzzy-find packages for quick install
- **Option exploration**: browse NixOS/HM options interactively
- **Aspect authoring**: quickly look up available options when writing aspects
