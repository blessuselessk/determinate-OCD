# Extensions, plugins, and skills for AI agents.
{ ... }:
{
  thegreenroom.augment = { };
}





















3 skills

§§§
my-skill/
├── SKILL.md          # Required: instructions + metadata
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
└── assets/           # Optional: templates, resources
----

Field	Required	Constraints
name	Yes	Max 64 characters. Lowercase letters, numbers, and hyphens only. Must not start or end with a hyphen.
description	Yes	Max 1024 characters. Non-empty. Describes what the skill does and when to use it.
license	No	License name or reference to a bundled license file.
compatibility	No	Max 500 characters. Indicates environment requirements (intended product, system packages, network access, etc.).
§§§§






## toDDO - CONSIDER HOW TO PARTITION MANIFJETS AT THE TOP LEVEL, SO THAT SKILLS/MCPS/COMMANDS/WORKFLOWS/ETC CAN LIVE IN THEIR OWN ASPECTSS

# jj workspace hooks for Claude Code's EnterWorktree tool.
# Replaces git worktrees with jj workspaces so agents share the repo store.
# See: https://github.com/hmerrilees/jj-workspace-claude-code-compat
{ ... }:
{
  thegreenroom.jj-claude-compat = { };
}
