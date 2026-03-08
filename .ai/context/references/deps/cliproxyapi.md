# cliproxyapi

> Self-hosted AI API proxy — OpenAI/Gemini/Claude-compatible endpoints as a NixOS/darwin service.

Source: `github:benjaminkitt/nix-cliproxyapi`

### Purpose

Proxy service exposing unified API endpoints compatible with OpenAI, Gemini, and Claude. Runs as a systemd (NixOS) or launchd (macOS) service with declarative Nix configuration.

### Editions

| Edition | Features | License |
|---------|----------|---------|
| Base | Core proxy | MIT |
| Plus | +Copilot, Kiro providers | MIT |
| Business | +User management, billing, web UI | SSPL |

### NixOS Setup

```nix
services.cliproxyapi = {
  enable = true;
  openFirewall = true;  # default port 8317 (8318 for business)
};

# Business edition with PostgreSQL
services.cliproxyapi = {
  enable = true;
  package = pkgs.cliproxyapiBusiness;
  storage = {
    type = "postgresql";
    connectionString = "...";
  };
};
```

### Storage Backends

- Local filesystem
- Git repositories
- PostgreSQL
- S3-compatible storage

### Use Cases

- **Unified AI gateway**: single endpoint for multiple LLM providers
- **Self-hosted proxy**: keep API keys server-side, expose to local agents
- **Multi-user access**: business edition for team API management
