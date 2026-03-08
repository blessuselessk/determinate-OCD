# luminous-nix

> Natural language interface for NixOS — converts plain English into nix commands via regex/heuristic matching.

Source: `github:Luminous-Dynamics/luminous-nix`

### Purpose

Maps natural language requests to nix package management operations. Regex-first approach (no LLM), sub-10ms intent recognition, fuzzy typo correction. Dry-run by default. Preview-only on non-NixOS.

### Syntax

```bash
# Natural language commands
luminous "install firefox"
luminous "search text editor"
luminous "remove vim"
luminous "update system"
luminous "setup python"
luminous "edit photo"
luminous "monitor system"
luminous "setup postgres"
```

### Key Features

- 70+ recognized patterns across dev, graphics, system, gaming, databases
- Intent recognition: <10ms, cache hits: 0.01ms
- Fuzzy matching for typo correction (100% on common misspellings)
- Dry-run mode by default for safety
- Animated progress indicators

### Use Cases

- **Accessible NixOS**: natural language package management for new users
- **Quick operations**: faster than remembering exact nix syntax
- **Safe exploration**: dry-run default prevents accidental changes
