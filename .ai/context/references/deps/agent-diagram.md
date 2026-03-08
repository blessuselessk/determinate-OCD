# agentDiagram

> Reactive diagram authoring environment (D2-first) powered by Nix Flakes with live preview.

Source: `github:jason9075/agentDiagram`

### Purpose

Auto-compiles D2 diagram files and maintains a live preview as you edit. Eliminates manual render cycles for architecture and sequence diagrams.

### Setup

```bash
just init
just dev
```

### Syntax

D2 diagram language — save `.d2` files in `diagrams/`, auto-rendered to PNG in `output/`:

```d2
User -> Service: request
Service -> User: response
```

### Requirements

- Nix with flakes enabled
- Wayland session (uses `imv` for preview)

### Use Cases

- **Architecture visualization**: diagram system relationships and data flows
- **AI-assisted design**: generate `.d2` source from natural language prompts
- **Workflow documentation**: sequence diagrams for component interactions
