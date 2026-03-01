{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      pkgsWithNuenv = pkgs.extend inputs.nuenv.overlays.default;

      # linkFarm so Typst resolves @local/promptyst:0.2.0
      promptystPackagePath = pkgs.linkFarm "promptyst-packages" [
        {
          name = "local/promptyst/0.2.0";
          path = inputs.promptyst;
        }
      ];

      descriptions = ./_helpers/descriptions;
      proseAgents = ./../../../.ai/agents;
      proseInstructions = ./../../../.ai/instructions;
      proseSkills = ./../../../.ai/skills;
      proseWorkflows = ./../../../.ai/workflows;
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
        PROSE_AGENTS_DIR = "${proseAgents}";
        PROSE_INSTRUCTIONS_DIR = "${proseInstructions}";
        PROSE_SKILLS_DIR = "${proseSkills}";
        PROSE_WORKFLOWS_DIR = "${proseWorkflows}";
        PROSE_RENDER_TEMPLATE = "./render-prose.typ";
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
        # Install rendered PROSE primitives
        if [ -d "${contextDocs}/prose" ]; then
          for dir in ${contextDocs}/prose/*/; do
            type=$(basename "$dir")
            case "$type" in
              skills)
                for skilldir in "$dir"*/; do
                  name=$(basename "$skilldir")
                  mkdir -p "$target/.ai/skills/$name"
                  install -m 644 "$skilldir/SKILL.md" "$target/.ai/skills/$name/SKILL.md"
                  echo "Wrote .ai/skills/$name/SKILL.md"
                done
                ;;
              *)
                mkdir -p "$target/.ai/$type"
                for f in "$dir"*.md; do
                  [ -e "$f" ] || continue
                  install -m 644 "$f" "$target/.ai/$type/$(basename "$f")"
                  echo "Wrote .ai/$type/$(basename "$f")"
                done
                ;;
            esac
          done
        fi
        # Install ref files to .github/
        if [ -d "${contextDocs}/refs" ]; then
          for dir in ${contextDocs}/refs/*/; do
            name=$(basename "$dir")
            mkdir -p "$target/.github/$name"
            for f in "$dir"/*.md; do
              [ -e "$f" ] || continue
              install -m 644 "$f" "$target/.github/$name/$(basename "$f")"
              echo "Wrote .github/$name/$(basename "$f")"
            done
          done
        fi
      '';
      # update-dep-refs: fetch dep documentation from Context7 API / GitHub README
      updateDepRefs = pkgs.writeShellScriptBin "update-dep-refs" ''
        set -euo pipefail
        target="''${1:-.}"
        export TARGET_DIR="$target"
        ${pkgs.nushell}/bin/nu ${./_helpers/update-dep-refs.nu}
      '';

      # Staleness check for dep refs: verify manifest entries have .md files.
      # Only checks file existence (no network fetch in sandbox).
      depManifest = ./../../../.ai/context/references/deps/manifest.toml;
      depsDir = ./../../../.ai/context/references/deps;
      checkDepRefsFresh = pkgs.runCommand "check-dep-refs-fresh" { } ''
        missing=""
        # Parse dep names from manifest using grep
        for name in $(${pkgs.gnugrep}/bin/grep '^name = ' ${depManifest} | ${pkgs.gnused}/bin/sed 's/^name = "\(.*\)"/\1/'); do
          if [ ! -f "${depsDir}/$name.md" ]; then
            missing="$missing $name.md"
          fi
        done
        if [ -n "$missing" ]; then
          echo "ERROR: Missing dep reference files:$missing"
          echo "Run: nix run .#update-dep-refs"
          exit 1
        fi
        echo "Dep references are up to date."
        touch $out
      '';

      # Staleness check: verify installed files match built output.
      # Fails with instructions to run write-context-docs if out of date.
      checkContextDocsFresh = pkgs.runCommand "check-context-docs-fresh" { } ''
        stale=""

        # Check .ai/ output files
        for f in ${contextDocs}/*.md; do
          name=$(basename "$f")
          if [ "$name" = "AGENTS.md" ]; then
            target="${./../../../.ai}/AGENTS.md"
          else
            target="${./../../../.ai/output}/$name"
          fi
          if [ ! -f "$target" ] || ! diff -q "$f" "$target" >/dev/null 2>&1; then
            stale="$stale $name"
          fi
        done

        # Check per-primitive AGENTS.md
        for dir in ${contextDocs}/primitive-agents/*/; do
          name=$(basename "$dir")
          target="${./../../../.ai}/$name/AGENTS.md"
          if [ ! -f "$target" ] || ! diff -q "$dir/AGENTS.md" "$target" >/dev/null 2>&1; then
            stale="$stale .ai/$name/AGENTS.md"
          fi
        done

        # Check rendered PROSE primitives
        if [ -d "${contextDocs}/prose" ]; then
          for dir in ${contextDocs}/prose/*/; do
            type=$(basename "$dir")
            case "$type" in
              skills)
                for skilldir in "$dir"*/; do
                  sname=$(basename "$skilldir")
                  target="${./../../../.ai}/skills/$sname/SKILL.md"
                  if [ ! -f "$target" ] || ! diff -q "$skilldir/SKILL.md" "$target" >/dev/null 2>&1; then
                    stale="$stale .ai/skills/$sname/SKILL.md"
                  fi
                done
                ;;
              *)
                for f in "$dir"*.md; do
                  [ -e "$f" ] || continue
                  fname=$(basename "$f")
                  target="${./../../../.ai}/$type/$fname"
                  if [ ! -f "$target" ] || ! diff -q "$f" "$target" >/dev/null 2>&1; then
                    stale="$stale .ai/$type/$fname"
                  fi
                done
                ;;
            esac
          done
        fi

        # Check ref files
        if [ -d "${contextDocs}/refs" ]; then
          for dir in ${contextDocs}/refs/*/; do
            name=$(basename "$dir")
            for f in "$dir"/*.md; do
              [ -e "$f" ] || continue
              fname=$(basename "$f")
              target="${./../../../.github}/$name/$fname"
              if [ ! -f "$target" ] || ! diff -q "$f" "$target" >/dev/null 2>&1; then
                stale="$stale .github/$name/$fname"
              fi
            done
          done
        fi

        if [ -n "$stale" ]; then
          echo "ERROR: Generated context docs are stale:$stale"
          echo "Run: nix run .#write-context-docs"
          exit 1
        fi
        echo "Context docs are up to date."
        touch $out
      '';
    in
    {
      packages.context-docs = contextDocs;
      packages.write-context-docs = writeContextDocs;
      packages.update-dep-refs = updateDepRefs;
      checks.context-compile = contextDocs;
      checks.context-docs-fresh = checkContextDocsFresh;
      checks.dep-refs-fresh = checkDepRefsFresh;
    };
}
