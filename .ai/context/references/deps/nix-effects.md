# nix-effects

> Type-checking kernel, algebraic effects, and dependent types in pure Nix.

Source: `github:kleisli-io/nix-effects`

### Purpose

nix-effects adds an MLTT (Martin-Lof Type Theory) proof checker to Nix that verifies values, computes universe levels, and extracts certified functions from proof terms. Catches configuration errors at evaluation time before anything builds.

### Setup

```nix
{
  inputs.nix-effects.url = "github:kleisli-io/nix-effects";
  outputs = { nix-effects, ... }:
    let fx = nix-effects.lib;
    in { /* use fx.types, fx.run, etc. */ };
}
```

### Type System

```nix
# Primitive types
fx.types.String
fx.types.Int
fx.types.Bool
fx.types.Float
fx.types.Path

# Compound types
fx.types.Record { name = fx.types.String; port = fx.types.Int; }
fx.types.ListOf fx.types.String
fx.types.Maybe fx.types.Int
fx.types.Either fx.types.String fx.types.Int
fx.types.Variant { tcp = fx.types.Int; unix = fx.types.Path; }

# Refinement types — narrow any type with a predicate
Nat = fx.types.refined "Nat" fx.types.Int (x: x >= 0);
Port = fx.types.refined "Port" fx.types.Int (x: x >= 1 && x <= 65535);
```

### Algebraic Effects

```nix
# Create effect
myEffect = fx.send "MyEffect" someValue;

# Compose sequentially
pipeline = fx.bind firstEffect (result: fx.send "Next" result);

# Run with handler
fx.run handler pipeline;
```

### Use Cases

- **Cross-field validation**: enforce that public-facing services (bind = "0.0.0.0") must use HTTPS
- **Config contracts**: define and enforce typed interfaces between aspects
- **Aspect type safety**: catch misconfigurations at eval time, not deploy time
- **Policy enforcement**: encode organizational security/compliance rules as types
