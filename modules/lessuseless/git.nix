{ ... }:
{
  lessuseless.git.homeManager = {
    programs.git = {
      enable = true;
      signing = {
        key = "~/.ssh/id_ed25519.pub";
        signByDefault = true;
        format = "ssh";
      };
      settings.user = {
        name = "Ashley Barr";
        email = "261668912+blessuselessk@users.noreply.github.com";
      };
    };
  };
}
