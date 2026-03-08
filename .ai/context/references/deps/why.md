# why

> CLI that explains programming errors using a locally-embedded LLM — fully offline, no API keys.

Source: `github:jamesbrink/why`

### Purpose

Single-binary tool (~680MB with embedded model) that explains error messages using local LLM inference. Parses stack traces for Python, Rust, JavaScript, Go, Java, and C++.

### Syntax

```bash
why "error message"                    # direct query
cargo build 2>&1 | why                 # pipe errors
why --stream "error"                   # stream response
why --watch /var/log/app.log           # monitor logs
why --capture -- cargo build           # auto-capture failures
why --json "error"                     # JSON output
```

### Key Features

- Single binary, no internet or API keys required
- Models from 135MB to 680MB
- Real-time streaming responses
- Watch mode for continuous log monitoring
- Shell integration for auto-explain on command failure
- Daemon mode for fast repeated queries
- Stack trace parsing for 6 languages

### Installation

```bash
nix run github:jamesbrink/why
```

### Use Cases

- **Error triage**: instant explanation of cryptic messages
- **Log monitoring**: watch mode for production/dev logs
- **CI/CD debugging**: pipe build failures through why
- **Offline dev**: full functionality without connectivity
