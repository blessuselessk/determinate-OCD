# POP (Pure Object Prototypes)

> Prototype object system for Nix with multiple inheritance -- formalizes and extends the extension mechanisms already present in nixpkgs.

Source: <https://github.com/divnix/POP>

## Purpose

Nix's existing extension mechanisms (`lib.fixedPoints.composeExtensions`, overlays, overrides) are functionally equivalent to single-inheritance prototype systems but lack formal structure and multiple-inheritance capabilities. POP introduces a proper prototype-based object system for Nix that supports multiple inheritance via DAG-structured prototype composition, replacing ad-hoc patterns with a unified, well-founded design drawn from four decades of object system research (Self, CLOS, Jsonnet).

## Setup / Syntax

POP is a Nix flake. Add it as an input and use the library functions from `POP.nix`:

```nix
inputs.POP.url = "github:divnix/POP";
```

Run tests with:

```bash
nix flake check
```

The implementation and full API are in the heavily commented `POP.nix` source file.

## Key Features / API

### Core Concepts

- **Prototype (Extension)**: A function `self: super: { ... }` that returns an attrset of bindings overriding the `super` attrset. Also known as "mixin" or "trait" in other systems.
- **Instance**: The fixed-point value computed from composing prototypes. Contains fields (values) and methods (operations).
- **Pop/Object**: An entity combining prototype metadata (`__meta__`) with instance field values.
- **Base Entity**: The starting value for fixed-point computation, typically `{}`.

### Inheritance Model

- **Single Inheritance**: Prototypes form a linear list (what existing Nix mechanisms support).
- **Multiple Inheritance**: Each prototype can have multiple direct `supers`, forming a DAG. POP computes a **precedence list** -- a topological sort of the DAG into a total order that preserves the partial order of prototype appearance.
- **Defaults**: Incremental base-entity specifications included in each prototype; merged from all prototypes in the precedence list to compute the effective base. Equivalent to CLOS's "default slot value."
- **Supers**: An ordered list of direct parent prototypes from which a prototype inherits.

### Merge Semantics

The default merge function is:

```nix
mergeAttrs = A: B: B // A
```

This is customizable per-object to support richer merging strategies.

### Type Signatures (conceptual)

```
type Proto     = A: B: A B -> A | A <: B
type Extension = A: B: Exists C: A B -> C | B // C <: A <: B
type Default   = A: Exists C: C | C <: A
```

### Properties Enabled by Nix

- **Purity** ensures each prototype has a unique fixed-point instance, enabling safe composition with metadata.
- **Laziness** permits instance definitions without forcing all field computations.
- **Dynamic typing** enables fixed-point computations that would require dependent types in static systems.

## Use Cases

- **Cross-language package specifications**: Modularly handle common packaging aspects across Haskell, OCaml, Python, Go, and other ecosystems without separate hierarchies.
- **Multi-branch package management**: Mix "stable" and "unstable" branches across different packages without maintaining exponential manual precedence lists.
- **Modular library composition**: Independent library teams specify prototype dependencies without central coordination of inheritance ordering.
- **Disjoint aspect combination**: Compose prototypes addressing unrelated concerns (database, UI, networking) without manual integration.
- **Replacing ad-hoc Nix patterns**: Unify `lib/fixed-points.nix`, `lib/customisation.nix`, overlays, and overrides under a single coherent object protocol.

### Related Resources

- Design essay: `POP.md` in the repository
- Academic paper: "Prototype Object Orientation Functionally" (SFPW 2021) -- [PDF](http://fare.tunes.org/files/cs/poof.pdf)
- nixpkgs integration discussion: NixOS/nixpkgs PR #116275
