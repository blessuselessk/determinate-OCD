# purga

> CLI tool to pass command-line arguments to Nix flakes as JSON via a dedicated input.

Source: `github:nikolaiser/purga`

### Purpose

Enables dynamic argument passing to Nix flakes. Serializes CLI key-value pairs as JSON and injects them via a flake input (`purgaArgs` by default), so flake outputs can read runtime parameters.

### Syntax

```bash
# Pass arguments to a nix command
purga -a key1=value1 -a key2=value2 -- nix build .#package

# Array values (repeat same key)
purga -a tags=web -a tags=api -- nix build

# Custom input name
purga -i myArgs -a foo=bar -- nix build

# Works with any nix command
purga -a host=prod -- nixos-rebuild switch --flake .
```

### Flake Setup

```nix
{
  inputs.purgaArgs.url = "file+file:///dev/null";  # placeholder
  outputs = { purgaArgs, ... }:
    let args = builtins.fromJSON (builtins.readFile purgaArgs);
    in { /* use args.key1, args.key2, etc. */ };
}
```

### Use Cases

- **Parameterized builds**: pass host, env, or feature flags at build time
- **Dynamic NixOS configs**: inject values without editing flake.nix
- **CI/CD pipelines**: pass build matrix parameters to flake outputs
