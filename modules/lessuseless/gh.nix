{ ... }:
{
  lessuseless.gh.homeManager = {
    programs.gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
  };
}
