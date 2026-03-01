{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      pkgsWithNuenv = pkgs.extend inputs.nuenv.overlays.default;

      # linkFarm so Typst resolves @local/promptyst:0.1.0
      promptystPackagePath = pkgs.linkFarm "promptyst-packages" [
        {
          name = "local/promptyst/0.1.0";
          path = inputs.promptyst;
        }
      ];

      contextDocs = pkgsWithNuenv.nuenv.mkDerivation {
        name = "ocd-context-docs";
        src = ./_helpers;
        packages = [ pkgs.typst ];

        RENDER_TEMPLATE = "./render-aspect.typ";
        PROMPTYST_PACKAGE_PATH = "${promptystPackagePath}";

        # Bootstrap: hardcoded networking aspect description.
        # Production: extract from `nix eval .#den.aspects.*.description`
        ASPECT_NAMES = "networking";
        ASPECT_NETWORKING = ''
          [aspect]
          id = "ocd.networking"
          version = "0.1.0"
          role = "OpenClaw-aware networking aspect"

          [context]
          id = "networking-ctx"

          [[context.entries]]
          key = "firewall"
          value = "Ports 443 (HTTPS) and 22 (SSH) open externally"

          [[context.entries]]
          key = "gateway-port"
          value = "18789 loopback-only (proxied by Caddy)"

          [[constraints]]
          text = "Gateway and webhook ports stay loopback-only"

          [[steps]]
          text = "Configure NetworkManager"

          [[steps]]
          text = "Open firewall ports 443, 22"
        '';

        build = builtins.readFile ./_helpers/extract-and-render.nu;
      };
    in
    {
      packages.context-docs = contextDocs;
      checks.context-compile = contextDocs;
    };
}
