# jj workspace hooks for Claude Code's EnterWorktree tool.
# Replaces git worktrees with jj workspaces so agents share the repo store.
# See: https://github.com/hmerrilees/jj-workspace-claude-code-compat
{ ... }:
{
  thegreenroom.jj-claude-compat = { };
}
