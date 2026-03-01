# Stack Reference

On-demand reference for the determinate-OCD dependency stack. Load when you need to understand what a dependency does or how layers connect.

## Layer Architecture

```
Layer 0: Context Engineering  <- design discipline (AGENTS.md, _context/, tool conventions)
Layer 1: Determinate Systems  <- infrastructure (flakes, FlakeHub, remote deploy)
Layer 2: OpenClaw             <- AI gateway (Telegram, plugins, secrets)
Layer 3: Dendritic            <- structure (aspect-oriented config pattern + frameworks)
Layer 4: Core Plumbing        <- flake-parts, home-manager, agenix
```

## Layer 1 — Determinate Systems

| Component | Role |
|-----------|------|
| Determinate NixOS template | Starting point (`nix flake init --template ...`) |
| `determinate-nixd` | Nix daemon; `determinate-nixd login` unlocks FlakeHub cache |
| `fh` (FlakeHub CLI) | Remote deploy: `fh apply nixos "org/flake/*#nixosConfigurations.<host>"` |
| Determinate NixOS ISO | Custom ISO with Determinate Nix, `fh`, NetworkManager, flakes |

## Layer 2 — OpenClaw

| Component | Role |
|-----------|------|
| `github:openclaw/nix-openclaw` | `programs.openclaw` Home Manager module |

- Runs as systemd user service (`openclaw-gateway.service`)
- Gateway: `127.0.0.1:18789` (loopback), Webhook: `127.0.0.1:8787` (loopback)
- Production: Caddy reverse proxy for TLS on port 443
- Bundled plugins: `programs.openclaw.bundledPlugins.<name>.enable`
- Custom plugins: `programs.openclaw.customPlugins = [...]`
- Secrets: always file paths via agenix, never inline

## Layer 3 — Dendritic Ecosystem

### Pattern origin

| Repo | What |
|------|------|
| `github:mightyiam/dendritic` | Canonical pattern definition |
| `github:vic/dendritic` | Annotated fork with examples |

### Core primitives

| Repo | What |
|------|------|
| `github:vic/import-tree` | Auto-imports all `.nix` under a dir. Default filter: `/_` infix excluded. Chainable builder API. |
| `github:vic/flake-aspects` | `transpose`, `provides`, `includes` for aspect composition |
| `github:vic/flake-file` | Generates `flake.nix` from module options. Regenerate: `nix run .#write-flake` |

### Framework

| Repo | What |
|------|------|
| `github:vic/den` | Batteries-included: `den.hosts`, `den.homes`, `den.default.includes`, angle-bracket syntax, multi-platform |
| `github:vic/denful` | Curated reusable facets (cherry-pickable) |
| `github:vic/dendrix` | Community distribution of dendritic modules |

### Reference implementation

| Repo | What |
|------|------|
| `github:vic/vix` (den branch) | Vic's config. Three namespaces: `community/vix/`, `vic/`, `my/`. Study for layout patterns. |

## Layer 4 — Core Plumbing

| Repo | Role |
|------|------|
| `github:hercules-ci/flake-parts` | Module system for flake outputs |
| `github:nix-community/home-manager` | Home Manager (homeManager class + OpenClaw module host) |
| `github:ryantm/agenix` | Secrets: encrypted at rest, decrypted at activation to `/run/agenix/*` |

## Dependency Flow

```
Determinate Systems -> OpenClaw -> Dendritic pattern -> import-tree / flake-aspects / flake-file
  -> den / denful -> dendrix -> This project (determinate-OCD)
```

## Den API Quick Reference

### Hosts and users

```nix
den.hosts.x86_64-linux.<hostname>.users.<user>.aspect = "<user>-profile";
```

### Named aspects

```nix
den.aspects.<name>.includes = [ <namespace.aspect> ... ];
den.aspects.<name>.nixos = { ... };  # any class name accepted
```

### Namespaces

```nix
imports = [
  (inputs.den.namespace "ocd" true)      # community (exposed)
  (inputs.den.namespace "<user>" false)   # local only
  (inputs.den.namespace "<infra>" false)  # local only
];
```

### Default includes

```nix
den.default.includes = [
  <ocd.networking>
  <ocd.bootloader>
  <<user>.shell>
];
```

### Standalone home-manager

```nix
den.homes.x86_64-linux.<user> = { aspect = "<user>-profile"; };
```
