# clap-nix

> Pure Nix command-line argument parser — build CLIs entirely in the Nix language.

Source: `github:vic/clap-nix`

### Purpose

Parses command-line arguments into structured attribute sets in pure Nix. No shell scripts or external tools — define CLI structure with `lib.mkOption`, parse with `clap`, get typed results.

### Syntax

```nix
# 1. Define CLI structure ("slac" tree)
slac = {
  short.v = lib.mkEnableOption "verbose";
  long.output = lib.mkOption { type = lib.types.str; default = "."; };
  command.build = {
    long.target = lib.mkOption { type = lib.types.str; };
    argv = lib.mkOption { type = lib.types.listOf lib.types.str; };
  };
};

# 2. Parse arguments
result = clap slac [ "--verbose" "build" "--target" "x86_64" "file.nix" ];

# 3. Access typed results
result.opts.short.v   # true
result.opts.command.build.long.target  # "x86_64"
result.opts.command.build.argv  # [ "file.nix" ]
```

### Key Features

- Long (`--option`) and short (`-o`) flags
- Boolean negation (`--no-verbose`)
- Collapsed short options (`-abc` = `-a -b -c`)
- Type-safe values (any Nix type, not just strings)
- Nested subcommands (git-like hierarchies)
- Default subcommands
- Module integration via `lib.evalModules` for aliases
- Typed positional arguments per command

### Use Cases

- **Nix-native CLI tools**: build utilities without leaving Nix
- **Aspect tooling**: typed CLI wrappers for aspect management scripts
- **Config management**: parse and validate CLI args with Nix module system
