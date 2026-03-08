# claude-code-lsps

> Collection of Language Server Protocol (LSP) plugins for Claude Code, providing IDE-like intelligence with real-time code analysis, symbol navigation, and error detection across 23 programming languages.

Source: `github:boostvolt/claude-code-lsps`

## Purpose

claude-code-lsps brings LSP integration to Claude Code through a plugin marketplace. It exposes language server capabilities via two mechanisms:

1. **LSP Tool** -- 9 operations: `goToDefinition`, `findReferences`, `hover`, `documentSymbol`, `workspaceSymbol`, `goToImplementation`, `prepareCallHierarchy`, `incomingCalls`, `outgoingCalls`
2. **Automatic Diagnostics** -- Real-time error and warning detection running independently

______________________________________________________________________

### Setup

Source: https://github.com/boostvolt/claude-code-lsps

**Step 1: Add the marketplace**

```
claude
/plugin marketplace add boostvolt/claude-code-lsps
```

**Step 2: Install individual language plugins**

```
/plugin install bash-language-server@claude-code-lsps
/plugin install pyright@claude-code-lsps
/plugin install rust-analyzer@claude-code-lsps
/plugin install nixd@claude-code-lsps
```

Or browse interactively:

```
/plugin
```

**Compatibility note**: Requires Claude Code v2.1.0 or later. Versions v2.0.69 through v2.0.x have a broken LSP race condition.

______________________________________________________________________

### Supported Languages

Source: https://github.com/boostvolt/claude-code-lsps

| Language | LSP Server | Extensions |
|----------|-----------|------------|
| Bash/Shell | bash-language-server | .sh, .bash, .zsh, .ksh |
| C/C++/Obj-C | clangd | .c, .h, .cpp, .hpp, .cc, .m, .mm |
| C# | OmniSharp | .cs, .csx |
| Clojure | clojure-lsp | .clj, .cljs, .cljc, .edn |
| Dart/Flutter | Dart SDK | .dart |
| Elixir | elixir-ls | .ex, .exs |
| Gleam | gleam | .gleam |
| Go | gopls | .go |
| Java | jdtls | .java |
| Kotlin | kotlin-lsp | .kt, .kts |
| Lua | lua-language-server | .lua |
| Nix | nixd | .nix |
| OCaml | ocaml-lsp | .ml, .mli |
| PHP | Intelephense | .php, .phtml |
| Python | pyright | .py, .pyi |
| Ruby | Solargraph | .rb, .rake, .gemspec |
| Rust | rust-analyzer | .rs |
| Swift | sourcekit-lsp | .swift |
| Terraform | terraform-ls | .tf, .tfvars |
| TypeScript/JS | vtsls | .ts, .tsx, .js, .jsx, .mjs, .cjs |
| YAML | yaml-language-server | .yaml, .yml |
| Zig | zls | .zig, .zon |

______________________________________________________________________

### Configuration -- .lsp.json

Source: https://github.com/boostvolt/claude-code-lsps

Each plugin uses a `.lsp.json` file to configure its LSP server.

```json
{
  "go": {
    "command": "gopls",
    "extensionToLanguage": {
      ".go": "go"
    }
  }
}
```

**Required fields:**
- `command` (string) -- executable command to launch the LSP server
- `extensionToLanguage` (object) -- maps file extensions to language identifiers

**Optional fields:**

| Field | Type | Description |
|-------|------|-------------|
| `args` | string[] | CLI arguments for the server |
| `transport` | string | `"stdio"` (default) or `"socket"` |
| `env` | object | Environment variables at startup |
| `initializationOptions` | object | LSP initialization parameters |
| `settings` | object | Server config via `workspace/didChangeConfiguration` |
| `workspaceFolder` | string | Root directory for the server |
| `startupTimeout` | number | Milliseconds to wait for init |
| `shutdownTimeout` | number | Milliseconds for graceful shutdown |
| `restartOnCrash` | boolean | Auto-restart on failure |
| `maxRestarts` | number | Max restart attempts (default: 3) |

______________________________________________________________________

### Creating Custom Plugins

Source: https://github.com/boostvolt/claude-code-lsps

Directory structure for a custom LSP plugin:

```
my-lsp/
  .claude-plugin/
    plugin.json
  .lsp.json
  hooks/
    hooks.json
    check-my-lsp.sh
```

**Plugin manifest** (`.claude-plugin/plugin.json`):

```json
{
  "name": "gopls",
  "description": "Go language server",
  "version": "1.0.0",
  "author": { "name": "Your Name" },
  "license": "MIT",
  "repository": "https://github.com/boostvolt/claude-code-lsps"
}
```

______________________________________________________________________

## Use Cases

- **Code navigation**: Jump to definitions, find references, view call hierarchies across large codebases
- **Real-time diagnostics**: Catch type errors, unused imports, and warnings without leaving the CLI
- **Multi-language projects**: Install only the LSPs you need for your stack
- **Custom LSP wiring**: Create plugins for LSP servers not yet in the marketplace
