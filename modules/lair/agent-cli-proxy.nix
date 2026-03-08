# AI API proxy services — gateway layers that agent CLIs talk through.
#
#   cliproxyapi (github:benjaminkitt/nix-cliproxyapi)
#     Self-hosted proxy exposing OpenAI/Gemini/Claude-compatible API endpoints.
#     NixOS/darwin modules for systemd/launchd service management.
#     Storage backends: local, git, PostgreSQL, S3.
#     Editions: base (MIT), plus (+Copilot/Kiro, MIT), business (+billing/UI, SSPL).
#     Syntax: services.cliproxyapi = { enable = true; openFirewall = true; };
#
{ ... }:
{
  lair.agent-cli-proxy = { };
}
