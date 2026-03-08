# korora

> A tiny and fast composable type system for Nix, implemented entirely in Nix. Named after the little penguin (Korora), it provides runtime type validation without depending on the NixOS module system.

Source: `github:adisbladis/korora`

## Purpose

Korora addresses the need for lightweight runtime type validation in Nix. Rather than relying on the NixOS module system for type checking, it provides a standalone library of type constructors, validators, and combinators that work within pure Nix expressions. Types compose into complex schemas with both immediate and deferred verification.

______________________________________________________________________

### Verification Modes

Source: https://github.com/adisbladis/korora

Two approaches to type checking:

**`verify`** -- Returns an error string on failure, `null` on success (deferred):

```nix
{ korora }:
let
  t = korora.string;
  error = t.verify 1;
in if error != null then throw error else "ok"
# => throws "Expected type 'string' but value '1' is of type 'int'"
```

**`check`** -- Throws immediately on error, returns the value on success:

```nix
{ korora }:
let
  t = korora.string;
  value = t.check "hello";
in value
# => "hello"
```

______________________________________________________________________

### Primitive Types

Source: https://github.com/adisbladis/korora

| Type | Matches |
|------|---------|
| `string` | Nix strings |
| `int` | Integers |
| `float` | Floating point numbers |
| `number` | Either int or float |
| `bool` | Booleans |
| `null` | Null value |
| `path` | Nix paths |
| `pathLike` | Paths, derivations, or strings with path characteristics |
| `function` | Functions |
| `attrs` | Any attribute set |
| `list` | Any list |
| `derivation` | Derivations |
| `any` | Matches everything |
| `never` | Matches nothing |

______________________________________________________________________

### Polymorphic Types

Source: https://github.com/adisbladis/korora

Combinators for building complex types from simpler ones:

```nix
{ korora }:
let
  types = korora;
in {
  # Homogeneous list
  names = (types.listOf types.string).check [ "alice" "bob" ];

  # Attribute set with uniform values
  config = (types.attrsOf types.int).check { port = 8080; timeout = 30; };

  # Type alternatives
  id = (types.union [ types.string types.int ]).check "abc-123";

  # Type conjunction
  both = (types.intersection [ types.attrs types.derivation ]).check drv;

  # Nullable type (null or T)
  maybe = (types.option types.string).check null;
}
```

______________________________________________________________________

### Struct Types

Source: https://github.com/adisbladis/korora

Structs define attribute set schemas with field-level type constraints:

```nix
{ korora }:
let
  types = korora;

  person = types.struct "person" {
    name = types.string;
    age = types.int;
  };
in
  person.check { name = "Alice"; age = 30; }
```

**Struct configuration** via `.override`:

```nix
# Allow missing fields (total = false) and reject extra fields (unknown = false)
(types.struct "strict" {
  name = types.string;
}).override {
  total = false;    # default: true -- all fields required
  unknown = false;  # default: true -- extra attrs allowed
}
```

**Custom invariant checking:**

```nix
(types.struct "range" {
  min = types.int;
  max = types.int;
}).override {
  verify = v:
    if v.min > v.max
    then "min must be <= max"
    else null;
}
```

______________________________________________________________________

### Enum and Tuple Types

Source: https://github.com/adisbladis/korora

```nix
{ korora }:
let
  types = korora;

  # Enum -- constrained string values
  color = types.enum "color" [ "red" "green" "blue" ];
  c = color.check "red";  # => "red"

  # Tuple -- fixed-length typed sequence
  pair = types.tuple [ types.string types.int ];
  p = pair.check [ "age" 30 ];  # => [ "age" 30 ]
in { inherit c p; }
```

______________________________________________________________________

### Custom Type Definitions

Source: https://github.com/adisbladis/korora

Two constructors for building custom types:

```nix
{ korora }:
let
  inherit (korora) typedef typedef';

  # typedef -- boolean predicate (true = valid)
  positiveInt = typedef "positiveInt" (v: builtins.isInt v && v > 0);

  # typedef' -- returns error string or null
  nonEmpty = typedef' "nonEmpty" (v:
    if builtins.isString v && v != ""
    then null
    else "expected non-empty string"
  );
in {
  x = positiveInt.check 42;     # => 42
  y = nonEmpty.check "hello";   # => "hello"
}
```

______________________________________________________________________

### Function Type Checking with defun

Source: https://github.com/adisbladis/korora

`defun` creates type-checked function wrappers that validate arguments and return values:

```nix
{ korora }:
let
  types = korora;
  add = types.defun [ types.int types.int types.int ]
    (a: b: a + b);
in
  add 1 2  # => 3, with type checking on args and result
```

______________________________________________________________________

### Rename -- Recursive Types

Source: https://github.com/adisbladis/korora

The `rename` function prevents infinite recursion in self-referential type definitions:

```nix
{ korora }:
let
  types = korora;
  tree = types.attrsOf (
    types.rename "treeOrString" (types.union [
      types.string
      tree
    ])
  );
in
  tree.check {
    a = "leaf";
    b = { c = "nested leaf"; };
  }
```

______________________________________________________________________

## Use Cases

- **Configuration validation**: Type-check Nix configs without the module system
- **Library APIs**: Enforce argument types in public Nix library functions
- **Data schemas**: Validate structured data (JSON imports, TOML configs) at eval time
- **Recursive structures**: Model tree-like data with self-referential types
- **Lightweight alternative**: When the NixOS module system is too heavy for simple validation
