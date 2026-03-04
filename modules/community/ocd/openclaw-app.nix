# GP2 Client (darwin): installs openclaw package directly.
# The HM module (homeManagerModules.openclaw) doesn't support darwin yet,
# so we skip it and install the package + config file manually.
# For NixOS clients, use ocd.openclaw. For the gateway, see openclaw-gateway.nix.
{ inputs, ... }:
{
  ocd.openclaw-app = {
    darwin =
      { ... }:
      {
        nixpkgs.overlays = [ inputs.nix-openclaw.overlays.default ];
      };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          inputs.nix-openclaw.packages.${pkgs.stdenv.hostPlatform.system}.openclaw
        ];
      };
  };
}
