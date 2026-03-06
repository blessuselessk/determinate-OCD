# Agent CLI tools.
{ ... }:
{
  lair.agent-clis = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.claude-code ];
      };
  };
}
