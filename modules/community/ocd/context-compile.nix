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
      composabilitySchema = ./../../../.ai/context/primitive-composability-schema.yaml;
      agentsHeader = ./../../../.ai/AGENTS.md.header;

      contextDocs = pkgsWithNuenv.nuenv.mkDerivation {
        name = "ocd-context-docs";
        src = ./_helpers;
        packages = [ pkgs.typst ];

        RENDER_TEMPLATE = "./render-aspect.typ";
        AGENTS_TEMPLATE = "./render-agents-md.typ";
        PRIMITIVE_AGENTS_TEMPLATE = "./render-primitive-agents-md.typ";
        PROMPTYST_PACKAGE_PATH = "${promptystPackagePath}";
        DESCRIPTIONS_DIR = "${descriptions}";
        COMPOSABILITY_SCHEMA = "${composabilitySchema}";
        AGENTS_HEADER = "${agentsHeader}";

        build = builtins.readFile ./_helpers/extract-and-render.nu;
      };
      writeContextDocs = pkgs.writeShellScriptBin "write-context-docs" ''
        set -euo pipefail
        target="''${1:-.}"
        mkdir -p "$target/.ai" "$target/.ai/output"
        install -m 644 "${contextDocs}/AGENTS.md" "$target/.ai/AGENTS.md"
        echo "Wrote .ai/AGENTS.md"
        for f in ${contextDocs}/*.md; do
          name=$(basename "$f")
          if [ "$name" != "AGENTS.md" ]; then
            install -m 644 "$f" "$target/.ai/output/$name"
            echo "Wrote .ai/output/$name"
          fi
        done
        # Per-primitive AGENTS.md files
        for dir in ${contextDocs}/primitive-agents/*/; do
          name=$(basename "$dir")
          mkdir -p "$target/.ai/$name"
          install -m 644 "$dir/AGENTS.md" "$target/.ai/$name/AGENTS.md"
          echo "Wrote .ai/$name/AGENTS.md"
        done
      '';
    in
    {
      packages.context-docs = contextDocs;
      packages.write-context-docs = writeContextDocs;
      checks.context-compile = contextDocs;
    };
}
