# Hard guard: intercepts `git` in jj-managed repos and refuses to run.
# Uses a PATH-priority wrapper so it works regardless of Claude Code
# permission mode, shell, or tool. `command git` bypasses the guard.
{ ... }:
let
  guardScript = ../community/ocd/_helpers/git-jj-guard.sh;
in
{
  lair.jj-guard.homeManager =
    { pkgs, ... }:
    let
      git-jj-guard = pkgs.writeShellScriptBin "git" (builtins.readFile guardScript);
    in
    {
      # Use a dedicated PATH entry via sessionPath so the wrapper
      # shadows real git at shell level without colliding in
      # home-manager-path (where openclaw bundles its own git).
      home.file.".local/bin/git" = {
        source = "${git-jj-guard}/bin/git";
      };
      home.sessionPath = [ "$HOME/.local/bin" ];
    };
}
