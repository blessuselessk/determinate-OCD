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
          package = inputs.nix-openclaw.packages.${pkgs.stdenv.hostPlatform.system}.openclaw;
          exposePluginPackages = false; # batteries-included package already bundles plugin CLIs
          # Use instances.default (not enable=true) to go through the module type system.
          # The upstream defaultInstance is missing appDefaults.nixMode.
          instances.default = {
            enable = true;
            launchd.enable = false; # GP2: Mac is a node, gateway runs on fogell
            config.gateway = {
              mode = "remote";
              remote.url = "wss://fogell.serval-minor.ts.net"; # Tailscale Serve (HTTPS/443 → loopback:18789)
              # Token: OPENCLAW_GATEWAY_TOKEN env var, read from ~/.openclaw/.env at runtime
            };
          };
        };
      };
  };
}
