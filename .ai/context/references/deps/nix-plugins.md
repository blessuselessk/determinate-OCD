# nix-plugins

> Collection of native plugins for the Nix expression language, providing a controlled way to extend Nix with custom built-in functions without enabling blanket unsafe code execution.

Source: `github:shlevy/nix-plugins`

## Purpose

nix-plugins extends the Nix evaluator with custom built-in functions through its native plugin system. The primary component, `extra-builtins`, lets users define a controlled set of additional builtins via an external file, offering a middle ground between full safety and blanket `importNative`/`exec` access.

______________________________________________________________________

### Setup -- NixOS Configuration

Source: https://github.com/shlevy/nix-plugins

Install system-wide on NixOS by adding the plugin path to Nix's configuration:

```nix
{
  nix.extraOptions = ''
    plugin-files = ${pkgs.nix-plugins}/lib/nix/plugins
  '';
}
```

For non-NixOS systems, add to `~/.config/nix/nix.conf`:

```
plugin-files = /path/to/nix-plugins/lib/nix/plugins
```

______________________________________________________________________

### Key Features -- extra-builtins Plugin

Source: https://github.com/shlevy/nix-plugins

The `extra-builtins` plugin introduces one configuration setting and two built-in functions:

**Configuration:**
- `extra-builtins-file` -- path to a Nix file that defines additional builtins

**Built-in functions:**

| Function | Description |
|----------|-------------|
| `builtins.extraBuiltins` | Loads the file specified by `extra-builtins-file`. Grants access to `importNative` and `exec` primops even when unsafe native code evaluation is disabled. Returns `null` if the file does not exist. |
| `builtins.nix-cflags` | Returns the compiler flags needed to build native plugins compatible with the current Nix version. Flag details are in `nix-plugins-config.h.in`. |

______________________________________________________________________

### Security Model

Source: https://github.com/shlevy/nix-plugins

The architecture allows users to define a controlled set of extra builtins without granting blanket permission for arbitrary native code execution. This is important because:

- `importNative` and `exec` are powerful primops that can execute arbitrary code
- nix-plugins restricts their use to a single, administrator-controlled file
- The `extra-builtins-file` is loaded by the plugin, not by arbitrary Nix expressions
- This provides extensibility while maintaining a security boundary

______________________________________________________________________

### Writing an Extra Builtins File

Source: https://github.com/shlevy/nix-plugins

The file specified by `extra-builtins-file` receives `importNative` and `exec` as arguments and returns an attribute set of custom builtins:

```nix
{ importNative, exec, ... }:
{
  # Custom builtin that runs a command and returns its output
  myCommand = args: exec [ "/usr/bin/some-command" ] ++ args;

  # Custom builtin that loads a native plugin
  myNative = importNative /path/to/plugin.so "function_name";
}
```

These become available as `builtins.extraBuiltins.myCommand` and `builtins.extraBuiltins.myNative` in Nix expressions.

______________________________________________________________________

### Building Native Plugins

Source: https://github.com/shlevy/nix-plugins

Use `builtins.nix-cflags` to get the correct compiler flags for building plugins compatible with the running Nix version:

```bash
# Get flags for compiling against current Nix
nix eval --raw '(builtins.nix-cflags)'
```

The flags are defined in `nix-plugins-config.h.in` and ensure ABI compatibility.

______________________________________________________________________

## Use Cases

- **Custom evaluator extensions**: Add domain-specific builtins without patching Nix
- **Controlled exec access**: Allow specific commands in evaluation without enabling all unsafe operations
- **Native code integration**: Load compiled C/C++ functions as Nix builtins
- **Infrastructure automation**: Bridge Nix evaluation with external tools (databases, APIs, secret stores)
