{ ... }:
{
  lessuseless.shell.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.carapace
        pkgs.fzf
        pkgs.nushell
        pkgs.fish
      ];
    };
}
