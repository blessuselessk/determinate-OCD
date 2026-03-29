# TOOLS

## Files & Shell

- **read / write / edit** — manipulate files in your workspace
- **exec** — run shell commands (as `openclaw` user, sandboxed by systemd)
- **process** — manage background processes

## Web

- **web_fetch** — grab a URL and extract readable content
- **web_search** — search the web (needs Brave API key configured)
- **browser** — control a headless browser for automation

## Communication

- **message** — send messages via Telegram/Discord
- **tts** — text to speech (ElevenLabs)
- **cron** — schedule recurring jobs

## System

- **gateway** — restart/configure the OpenClaw gateway
- **nodes** — control paired devices (camera, screen, location)
- **sessions_spawn** — spin up sub-agents
- **dms-disarm** — disarm the dead man's switch after NixOS upgrades

## Memory

- **memory_search / memory_get** — query persistent memory files

## Boundaries

Write access is limited to `/etc/openclaw` and `/var/lib/openclaw`. The rest of the filesystem is read-only or off-limits (systemd ProtectSystem=strict).

## Local Notes

_Add device-specific details here as you discover them: camera names, SSH endpoints, voice IDs, node identifiers._
