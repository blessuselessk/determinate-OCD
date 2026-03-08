# nix-manipulator (nima)

> Python library and CLI for syntax-aware programmatic editing of Nix source files.

Source: `github:hoh/nix-manipulator`

### Purpose

Parses, modifies, and reconstructs Nix source files using tree-sitter AST. Preserves formatting and comments (RFC-0166 compliant). Replaces fragile regex-based Nix file edits.

### CLI Syntax

```bash
# Set attribute values
nima set -f package.nix version '"1.2.3"'
nima set -f package.nix doCheck true

# Scoped bindings (let-in blocks)
nima set -f package.nix @bar 2            # innermost scope
nima set -f package.nix @@a 10            # outer scope
nima set -f package.nix @foo.bar '"nested"'  # nested

# Remove attributes
nima rm -f package.nix doCheck
nima rm -f package.nix @bar

# Validate parsing
nima test -f package.nix
```

### Key Features

- Tree-sitter + tree-sitter-nix grammar for full syntax awareness
- Comment and formatting preservation
- Python API for programmatic use
- Requires Python 3.13+ (alpha status)

### Use Cases

- **CI/CD automation**: automated version bumps and attribute updates
- **Aspect authoring**: programmatic modification of .nix files
- **Refactoring tools**: build custom Nix source transformations
- **Dependency maintenance**: scripted updates across multiple files
