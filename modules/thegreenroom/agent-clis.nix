# Agent CLI tools.
{ ... }:
{
  thegreenroom.agent-clis = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.claude-code ];
      };
  };
}
