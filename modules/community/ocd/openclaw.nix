# GP2 Client: connects to remote OpenClaw gateway over Tailscale.
# For the gateway server aspect, see openclaw-gateway.nix.
{ inputs, ... }:
{
  flake-file.inputs.nix-openclaw = {
    url = "github:arubis/nix-openclaw/fix/rolldown-sandbox-shim"; # PR #63 — bird fix + v2026.2.25
    inputs.nixpkgs.follows = "nixpkgs";
  };

  ocd.openclaw = {
    nixos =
      { ... }:
      {
        nixpkgs.overlays = [ inputs.nix-openclaw.overlays.default ];
      };
    darwin =
      { ... }:
      {
        nixpkgs.overlays = [ inputs.nix-openclaw.overlays.default ];
      };
    homeManager =
      { pkgs, ... }:
      {
        imports = [ inputs.nix-openclaw.homeManagerModules.openclaw ];
        programs.openclaw = {
          enable = true;
          package = inputs.nix-openclaw.packages.${pkgs.stdenv.hostPlatform.system}.openclaw;
          config.gateway = {
            mode = "remote";
            url = "https://fogell:18789"; # Tailscale MagicDNS
          };
        };
      };
  };
}
