{
  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];
  den.default.nixos.system.stateVersion = "25.05";
  den.default.homeManager.home.stateVersion = "25.05";
}
