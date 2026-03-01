# import-tree

> Recursively imports Nix modules from a directory, providing a simple, extensible API for NixOS, home-manager, and flake-parts.

Source: `github:vic/import-tree`

### import-tree.match and import-tree.matchNot

Source: https://github.com/vic/import-tree/blob/main/README.md

Filters paths based on a regular expression. The regex must match the full path. Multiple filters require all to match.

````APIDOC
## import-tree.match and import-tree.matchNot

### Description
Filters paths based on a regular expression. The regex must match the full path. Multiple filters require all to match.

### Method
N/A (Function within Nix expression)

### Endpoint
N/A

### Parameters
#### Path Parameters
N/A

#### Query Parameters
N/A

#### Request Body
N/A

### Request Example
```nix
import-tree.match ".*/[a-z]+@(foo|bar)\.nix" ./some-dir
````

### Response

#### Success Response (200)

N/A

#### Response Example

N/A

````

--------------------------------

### import-tree.initFilter

Source: https://github.com/vic/import-tree/blob/main/README.md

Replaces the initial filter for the import tree. The default filter includes files with a `.nix` suffix and excludes paths containing `/_`.

```APIDOC
## import-tree.initFilter

### Description
Replaces the initial filter for the import tree. The default filter includes files with a `.nix` suffix and excludes paths containing `/_`. This function allows you to define custom inclusion/exclusion criteria.

### Method
N/A (Function within Nix expression)

### Endpoint
N/A

### Parameters
#### Path Parameters
N/A

#### Query Parameters
N/A

#### Request Body
N/A

### Request Example
```nix
# Include .nix files not containing '/ignored/'
import-tree.initFilter (p: lib.hasSuffix ".nix" p && !lib.hasInfix "/ignored/" p)

# Only include .md files
import-tree.initFilter (lib.hasSuffix ".md")
````

### Response

#### Success Response (200)

N/A

#### Response Example

N/A

````

--------------------------------

### Filtering Files with import-tree.filter and filterNot

Source: https://context7.com/vic/import-tree/llms.txt

Shows how to filter files based on a predicate function applied to their paths using `filter` and `filterNot`. Multiple filters can be chained and compose conjunctively.

```nix
let
  lit = import-tree.withLib lib;
in
  # Include only files with ".mod." in the path
  (lit.filter (lib.hasInfix ".mod.")).leafs ./modules

  # Multiple filters compose - files must match ALL predicates
  ((lit.filter (lib.hasInfix "b/")).filter (lib.hasInfix "_")).leafs ./tree
  # => [ ./tree/a/b/b_a.nix ]

  # Exclude files with "test" in path
  (lit.filterNot (lib.hasInfix "test")).leafs ./modules
````

______________________________________________________________________

### Regex Filtering with import-tree.match and matchNot

Source: https://context7.com/vic/import-tree/llms.txt

Demonstrates filtering files using regular expressions with `match` and `matchNot`. The regex must match the full path, and it uses `builtins.match` semantics.

```nix
let
  lit = import-tree.withLib lib;
in
  # Match files with underscore pattern in filename
  (lit.match ".*/[^/]+_[^/]+\.nix").leafs ./tree
  # => [ ./tree/a/a_b.nix ./tree/a/b/b_a.nix ]

  # Match specific naming conventions
  (lit.match ".*/[a-z]+@(foo|bar)\.nix").leafs ./some-dir

  # Exclude files matching pattern
  (lit.matchNot ".*/[^/]+_[^/]+\.nix").leafs ./tree/a/b
  # => [ ./tree/a/b/m.nix ]

  # Combine match with filter
  ((lit.match ".*a_b.nix").filter (lib.hasInfix "/a/")).leafs ./tree
  # => [ ./tree/a/a_b.nix ]
```

______________________________________________________________________

### Extend import-tree with custom methods using addAPI

Source: https://github.com/vic/import-tree/blob/main/README.md

The `import-tree.addAPI` function allows for extending the import-tree object with new methods. This enables the creation of custom, reusable functionalities tailored to specific project needs. The example demonstrates adding methods for maximal, feature, and minimal filtering.

```nix
import-tree.addAPI {
  maximal = self: self.addPath ./modules;
  feature = self: infix: self.maximal.filter (lib.hasInfix infix);
  minimal = self: self.feature "minimal";
}
```
