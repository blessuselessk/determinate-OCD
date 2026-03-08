# nix-filter

> Small self-contained source filtering library for Nix derivations -- precise control over which files enter the Nix store.

Source: <https://github.com/numtide/nix-filter>

## Purpose

When using `src = ./.;` in a Nix derivation, the entire project directory (including `.git`, editor artifacts, READMEs, and Nix config files) is copied into the Nix store on every build. nix-filter provides granular include/exclude control so that only the files needed for a build are copied, preventing unnecessary rebuilds when irrelevant files change.

## Setup / Syntax

### Flake input

```nix
{
  inputs.nix-filter.url = "github:numtide/nix-filter";

  outputs = { self, nixpkgs, nix-filter, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      filter = nix-filter.lib;
    in {
      # use filter { ... } as src
    };
}
```

### Direct import (non-flake)

```nix
let
  nix-filter = import ./path/to/nix-filter;
in
  # ...
```

### Top-level function signature

```nix
nix-filter {
  root = ./.;                          # path, required -- source directory
  name = "source";                     # string, optional -- derivation name
  include = [ ... ];                   # list of string|path|matcher, optional -- defaults to all
  exclude = [ ... ];                   # list of string|path|matcher, optional -- defaults to none
}
```

Each entry in `include`/`exclude` can be a relative path string, an absolute path, or a matcher function `(path -> type -> bool)`.

## Key Features / API

### Builtin Matchers

- **`matchExt "ext"`** -- matches files with the given extension (e.g., `matchExt "js"` matches all `.js` files).
- **`inDirectory "dir"`** -- matches a directory and everything inside it.
- **`isDirectory`** -- matches all paths that are directories.

### Matcher Combinators

- **`and a b`** -- combines two matchers with AND logic.
- **`or_ a b`** -- combines two matchers with OR logic (`or_` because `or` is a Nix keyword).

### Example

```nix
{ stdenv, nix-filter }:
stdenv.mkDerivation {
  name = "my-project";
  src = nix-filter {
    root = ./.;
    include = [
      "src"                          # include the src directory
      ./package.json                 # include a specific file
      (nix-filter.matchExt "js")     # include all .js files
    ];
    exclude = [
      ./main.js                      # exclude a specific file
    ];
  };
}
```

### Design Notes

- Uses `builtins.path` with recursive filtering internally.
- Ignored folders prevent recursion, so glob patterns like `**/*.js` require explicit folder inclusion (may create empty directories).
- Using only `exclude` without `include` is discouraged -- it is unlikely to reduce rebuilds substantially. Prefer explicit `include` lists.

## Use Cases

- **Monorepos**: Include only the subdirectory relevant to a particular derivation, ignoring unrelated packages.
- **Preventing spurious rebuilds**: Exclude documentation, CI configs, and Nix files that do not affect the build output.
- **Fine-grained source sets**: Combine `matchExt`, `inDirectory`, and path literals to define exactly which files a derivation depends on.
- **Extension-based filtering**: Use `matchExt` to include only source files (e.g., `.rs`, `.js`, `.typ`) and exclude everything else.
