{ ... }:
{
  lessuseless.shell.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.nushell
        pkgs.fish
      ];
    };
}
