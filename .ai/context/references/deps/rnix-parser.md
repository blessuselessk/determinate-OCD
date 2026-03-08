# rnix-parser

> A Nix language parser written in Rust, built on rowan for lossless syntax trees with full span and whitespace preservation.

Source: <https://github.com/nix-community/rnix-parser>

## Purpose

rnix-parser provides a Rust library for parsing Nix language source code into a concrete syntax tree (CST). Unlike AST-only parsers, it preserves all whitespace, comments, and span information, meaning printing the tree reproduces the original source byte-for-byte -- even for syntactically invalid input. This makes it suitable for tools that need to manipulate Nix code while preserving formatting: code formatters, linters, rename refactorings, syntax highlighters, and language servers.

## Setup / Syntax

Add to `Cargo.toml`:

```toml
[dependencies]
rnix = "0.14"
```

The crate is published on [crates.io](https://crates.io/crates/rnix).

### Parse from string

```rust
let ast = rnix::Root::parse(&content);

for error in ast.errors() {
    println!("error: {}", error);
}

println!("{:#?}", ast.tree());
```

### Parse from stdin (complete example)

```rust
use std::{io, io::Read};

fn main() {
    let mut content = String::new();
    io::stdin().read_to_string(&mut content).expect("could not read nix from stdin");
    let ast = rnix::Root::parse(&content);

    for error in ast.errors() {
        println!("error: {}", error);
    }

    println!("{:#?}", ast.tree());
}
```

### Parse from file

```rust
use std::{env, fs};

fn main() {
    for file in env::args().skip(1) {
        let content = fs::read_to_string(&file).expect("error reading file");
        let parse = rnix::Root::parse(&content);

        for error in parse.errors() {
            println!("error: {}", error);
        }
        println!("{:#?}", parse.tree());
    }
}
```

Try it interactively:

```sh
echo "[hello nix]" | cargo run --quiet --example from-stdin
```

## Key Features / API

### Core Types

| Type | Description |
|------|-------------|
| `Root` | Primary AST entry point; call `Root::parse(&str)` to parse Nix source |
| `Parse` | Result container holding the syntax tree and any parse errors |
| `SyntaxNode` | A node in the concrete syntax tree (type alias over rowan) |
| `SyntaxToken` | A leaf token in the tree |
| `SyntaxElement` | Union of `SyntaxNode` and `SyntaxToken` |
| `SyntaxKind` | Enum of all token and node types in the Nix grammar |
| `NixLanguage` | Language definition for rowan integration |
| `ParseError` | Enum describing parse failures |
| `TextRange` / `TextSize` | Span information types |
| `WalkEvent` | Tree traversal events (`Enter`, `Leave`) |
| `TokenAtOffset` | Iterator for tokens at a given text position |

### Key Functions

- **`rnix::Root::parse(input: &str) -> Parse`** -- parse Nix source into a syntax tree.
- **`parse.errors() -> &[ParseError]`** -- retrieve parse errors (tree is still available even with errors).
- **`parse.tree() -> Root`** -- get the root AST node.
- **`rnix::tokenize(input: &str)`** -- tokenize input into syntactic units without building a tree.
- **`match_ast!`** -- macro for matching `SyntaxNode` instances against typed AST node variants.
- **`T!`** -- helper macro for `SyntaxKind` literals.

### Rowan Foundation

rnix uses the [rowan](https://crates.io/crates/rowan) crate, which provides:

- Lossless syntax trees: all span information preserved, printing the tree reproduces original source exactly.
- Error recovery: even completely invalid input produces a tree (erroneous nodes are marked).
- Non-recursive tree walking via `WalkEvent` iterators.
- Cheap cloning and sharing of syntax nodes.

### AST Module

The `ast` module provides typed wrappers over raw `SyntaxNode` values, giving a type-safe way to traverse and query specific Nix constructs (let bindings, function definitions, attribute sets, etc.).

## Use Cases

- **Code formatting**: nixpkgs-fmt and alejandra use rnix to parse and reformat Nix code while preserving semantics.
- **Language servers**: rnix-lsp (now nil) uses rnix for IDE features like go-to-definition, completion, and diagnostics.
- **Syntax highlighting**: Lossless trees with full span information enable precise token-level highlighting.
- **Refactoring tools**: Rename identifiers, extract expressions, or restructure attribute sets programmatically.
- **Static analysis**: Walk the AST to detect patterns, lint for style violations, or extract metadata from Nix files.
- **GUI rendering**: Interactively render and explore Nix expressions (see nix-explorer).
