# nixseparatedebuginfod

> Downloads and provides debug symbols and source code for Nix derivations to gdb and other debuginfod-capable debuggers on demand.

Source: <https://github.com/symphorien/nixseparatedebuginfod>

## Purpose

Most NixOS software is stripped by default, making debugging difficult. While key packages use `separateDebugInfo = true` to isolate debug symbols into a separate output, accessing them requires manual setup. nixseparatedebuginfod automates this by serving debug symbols and source code on-the-fly through the debuginfod protocol, so debuggers like gdb and valgrind can fetch them transparently.

## Setup / Syntax

### NixOS >= 24.05 (built-in module)

```nix
services.nixseparatedebuginfod.enable = true;
```

### NixOS with flakes

```nix
{
  inputs.nixseparatedebuginfod.url = "github:symphorien/nixseparatedebuginfod";

  outputs = { nixpkgs, nixseparatedebuginfod, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixseparatedebuginfod.nixosModules.default
        { services.nixseparatedebuginfod.enable = true; }
      ];
    };
  };
}
```

### NixOS < 24.05 (fetchTarball)

```nix
{ config, pkgs, lib, ... }: {
  imports = [
    ((builtins.fetchTarball {
      url = "https://github.com/symphorien/nixseparatedebuginfod/archive/<rev>.tar.gz";
      sha256 = "<hash>";
    }) + "/module.nix")
  ];
  config.services.nixseparatedebuginfod.enable = true;
}
```

### Manual / non-NixOS

1. Build: `nix-build ./default.nix` or `cargo build --release`
2. Run the binary
3. Set the environment variable: `export DEBUGINFOD_URLS=http://127.0.0.1:1949`

### gdb configuration

Add to `~/.gdbinit` to suppress per-request confirmation prompts:

```
set debuginfod enabled on
```

For older nixpkgs (<= 22.11), override gdb to enable debuginfod support:

```nix
(gdb.override { enableDebuginfod = true; })
```

### valgrind support

valgrind needs `debuginfod-find` on PATH:

```nix
environment.systemPackages = [
  (lib.getBin (pkgs.elfutils.override { enableDebuginfod = true; }))
];
```

## Key Features / API

- **Automatic symbol fetching**: Debuggers request symbols via the debuginfod protocol; the service fetches and caches them automatically.
- **Source code serving**: Provides the original source code alongside debug info so debuggers can display source lines.
- **Single-option enablement**: Only `services.nixseparatedebuginfod.enable = true` is needed on NixOS.
- **Systemd integration**: Runs as a systemd service when the NixOS module is enabled.
- **Cache management**: Stores data in `~/.cache/nixseparatedebuginfod`; safe to delete (recreated on next startup).
- **Logging control**: Adjustable via `RUST_LOG` environment variable (`warn`, `error`, etc.).

## Use Cases

- **Debugging NixOS packages**: Run `gdb $(command -v nix)` and get full symbols and source automatically, without pre-downloading debug outputs.
- **Post-mortem analysis**: Analyze core dumps with full symbol information from the binary cache.
- **valgrind profiling**: Get meaningful stack traces from valgrind with debug symbols resolved on the fly.
- **Development workflows**: Debug any package built with `separateDebugInfo = true` without manually installing its debug output.

### Limitation

Only works for derivations built with `separateDebugInfo = true`. Stripped binaries without separate debug outputs cannot be debugged through this service.
