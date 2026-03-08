# jaillm

> Nix wrapper that sandboxes LLM CLI tools using jail.nix for isolated, secure access.

Source: `github:myme/jaillm`

### Purpose

Wraps LLM TUIs (Claude, Gemini, etc.) in Nix jail containers for sandboxed execution. Reproducible, isolated environments for AI tool access with controlled resource visibility.

### Setup

```nix
# jaillm.nix — configure which LLM tools and utilities to include
{
  # Tool selection and sandbox config
}
```

```bash
# Run directly
nix run github:myme/jaillm

# Or build Docker image
nix build .#dockerImage
docker load < result
```

### Key Features

- Sandboxed LLM execution via jail.nix
- Multiple LLM platforms (Claude, Gemini)
- Nix flakes for reproducible environments
- Docker containerization support
- Optional entry shell with included utilities

### Use Cases

- **Secure AI experimentation**: run LLM tools without full system access
- **Controlled agent environments**: sandbox agent CLIs for safety
- **Reproducible AI tooling**: Nix-defined LLM environments across machines
