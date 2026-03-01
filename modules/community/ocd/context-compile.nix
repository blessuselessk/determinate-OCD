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

      descriptions = ./_helpers/descriptions;

      contextDocs = pkgsWithNuenv.nuenv.mkDerivation {
        name = "ocd-context-docs";
        src = ./_helpers;
        packages = [ pkgs.typst ];

        RENDER_TEMPLATE = "./render-aspect.typ";
        PROMPTYST_PACKAGE_PATH = "${promptystPackagePath}";
        DESCRIPTIONS_DIR = "${descriptions}";

        build = builtins.readFile ./_helpers/extract-and-render.nu;
      };
    in
    {
      packages.context-docs = contextDocs;
      checks.context-compile = contextDocs;
    };
}
