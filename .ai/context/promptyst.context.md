______________________________________________________________________

## description: "Promptyst DSL — TOML/YAML prompt schema and Typst rendering reference"

# Promptyst Reference

Promptyst is a Typst package (`@local/promptyst:0.1.0`) that parses structured prompt descriptions (TOML or YAML) and renders them to Markdown.

## Schema Sections

A full prompt description has 6 top-level sections plus optional checkpoints:

| Section | Required | Purpose |
|---------|----------|---------|
| `aspect` | yes | Identity: `id`, `version`, `role` |
| `context` | no | Key-value entries: `id`, `entries[].key`, `entries[].value` |
| `constraints` | no | Rules: `text`, `severity` (security / operational / convention) |
| `steps` | no | Ordered actions: `text` |
| `inputs` | no | Parameters: `name`, `type`, `description` |
| `schema` | no | Output shape: `id`, `fields[].name`, `fields[].type`, `fields[].description` |
| `checkpoints` | no | Assertions: `id`, `after-step`, `assertion`, `on-fail` (halt / warn / skip) |

## TOML Format

```toml
[aspect]
id      = "ocd.networking"
version = "0.1.0"
role    = "OpenClaw-aware networking aspect"

[context]
id = "networking-ctx"

[[context.entries]]
key   = "firewall"
value = "Ports 443 and 22 open externally"

[[constraints]]
text     = "Gateway ports stay loopback-only"
severity = "security"

[[steps]]
text = "Enable NetworkManager"

[[inputs]]
name        = "hostname"
type        = "string"
description = "Target machine hostname"

[schema]
id = "networking-output"

[[schema.fields]]
name = "applied"
type = "bool"
description = "Whether config was applied"

[[checkpoints]]
id         = "verify-loopback"
after-step = 3
assertion  = "Gateway port not in allowedTCPPorts"
on-fail    = "halt"
```

## YAML Format

Equivalent structure, more readable for complex descriptions:

```yaml
aspect:
  id: "ocd.boot"
  version: "0.1.0"
  role: "Boot configuration aspect"

context:
  id: "boot-ctx"
  entries:
    - key: "bootloader"
      value: "systemd-boot via lanzaboote"

constraints:
  - text: "Secure Boot must remain enabled"
    severity: "security"

steps:
  - text: "Configure systemd-boot"

inputs:
  - name: "configurationLimit"
    type: "int"
    description: "Max boot generations to keep"

schema:
  id: "boot-output"
  fields:
    - name: "secure-boot"
      type: "bool"
      description: "Whether Secure Boot is active"

checkpoints:
  - id: "verify-secure-boot"
    after-step: 2
    assertion: "lanzaboote configured and keys present"
    on-fail: "halt"
```

## Render Routing

The Typst template (`render-aspect.typ`) routes based on which sections are present:

| Condition | Function | Output |
|-----------|----------|--------|
| All 6 sections + checkpoints | `render-prompt()` | Full structured prompt with checkpoints |
| `context` section present | `render-context()` | Context-only reference card |
| `schema` section only | `render-schema()` | Schema definition |
| Fallback | Raw heading | `# <aspect.id>` |

## Build Invocation

```bash
typst query \
  --input data-path=./description.toml \
  --input format=toml \
  render-aspect.typ "<output>" \
  --field value --one
```

The Nix build pipeline (`extract-and-render.nu`) automates this:

1. Globs `descriptions/*.{toml,yaml}` for discovery
1. Stages each file into the Typst build root
1. Runs `typst query` per file
1. Collects rendered Markdown into the output derivation

## File Locations

| What | Path |
|------|------|
| Description sources | `modules/community/ocd/_helpers/descriptions/*.{toml,yaml}` |
| Typst template | `modules/community/ocd/_helpers/render-aspect.typ` |
| Build script | `modules/community/ocd/_helpers/extract-and-render.nu` |
| Nix entry point | `modules/community/ocd/context-compile.nix` |
| Rendered output | `.ai/output/*.md` (via `nix run .#write-context-docs`) |
