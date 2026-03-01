## Context: dendritic-ctx
| Key | Value |
| --- | ----- |
| imports | flake-file.flakeModules.dendritic, den.flakeModules.dendritic (with `or {}` fallback) |
| input-nixpkgs | https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz |
| input-den | github:vic/den |
| input-flake-file | github:vic/flake-file |
| pattern | Takes `inputs` argument; flake-file.inputs declares the three foundational flake inputs |