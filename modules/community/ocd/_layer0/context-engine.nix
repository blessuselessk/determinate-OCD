# Layer 0 — Context Engine aspect (DESIGN ARTIFACT)
#
# STATUS: Inactive. This file lives under _layer0/ (excluded from import-tree
# by the /_  infix convention). To activate, move to:
#   modules/community/ocd/context-engine.nix
#
# PURPOSE: Regenerates _context/ directories after every system rebuild,
# keeping AI-readable context artifacts in sync with actual system state.
# This is the enforcement mechanism for the Layer 0 feedback loop:
#   rebuild → regenerate _context/ → agent reads → agent modifies → rebuild
#
# PREREQUISITES (must exist before activation):
#   - flake.nix with den, import-tree, and flake-parts wired
#   - At least one namespace with aspects defined
#   - A working nixos-rebuild or home-manager switch pipeline
#
# DESIGN NOTES:
#   - This aspect spans two classes: nixos (activation script) and
#     homeManager (user-level context for OpenClaw tools)
#   - The nixos class handles system-wide context generation
#   - The homeManager class exposes context to OpenClaw via well-known paths
#   - All _context/ artifacts are deterministic: same inputs → same outputs
#     (except change-log.md which is append-only)

{
  ocd.context-engine = {

    # -- NixOS class: system-level context generation --
    nixos =
      { pkgs, ... }:
      let
        # Directory where this flake's modules/ tree lives.
        # Adjust if your flake root differs from /etc/nixos.
        flakeRoot = "/etc/nixos";
        modulesDir = "${flakeRoot}/modules";

        # Namespaces to generate context for.
        # Each entry produces a _context/ dir within that namespace.
        namespaces = [
          "community/ocd"
          # Add <user> and <infra> namespaces here when they exist.
          # These are private (not Dendrix-shared) but still benefit
          # from Layer 0 context for local AI operations.
        ];

        # --- manifest.json generator ---
        # Produces a machine-readable inventory of aspects in a namespace:
        #   { aspects: [ { file, name, classes: [...] } ], generation, timestamp }
        #
        # Implementation sketch: walk the namespace dir, parse .nix files for
        # class attribute patterns (e.g. `nixos =`, `homeManager =`), extract
        # aspect names from filenames. In practice this would use nix eval
        # against the flake to get accurate class membership.
        generateManifest =
          namespace:
          pkgs.writeShellScript "gen-manifest-${builtins.replaceStrings [ "/" ] [ "-" ] namespace}" ''
            set -euo pipefail
            NS_DIR="${modulesDir}/${namespace}"
            CTX_DIR="$NS_DIR/_context"
            mkdir -p "$CTX_DIR"

            GENERATION=$(nixos-rebuild list-generations 2>/dev/null | head -1 | grep -oE '[0-9]+' | head -1 || echo "0")
            TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

            # Collect aspect files (skip _-prefixed dirs, non-.nix files)
            ASPECTS="[]"
            if [ -d "$NS_DIR" ]; then
              ASPECTS=$(find "$NS_DIR" -name '*.nix' -not -path '*/_*' | sort | while read -r f; do
                NAME=$(basename "$f" .nix)
                # Detect classes by grepping for class attribute patterns
                CLASSES=$(grep -oE '\.(nixos|homeManager|darwin|hjem)\s*=' "$f" 2>/dev/null \
                  | sed 's/\.\(.*\)\s*=/\1/' | sort -u | ${pkgs.jq}/bin/jq -R . | ${pkgs.jq}/bin/jq -s .)
                ${pkgs.jq}/bin/jq -n \
                  --arg file "$f" \
                  --arg name "$NAME" \
                  --argjson classes "$CLASSES" \
                  '{file: $file, name: $name, classes: $classes}'
              done | ${pkgs.jq}/bin/jq -s .)
            fi

            ${pkgs.jq}/bin/jq -n \
              --arg namespace "${namespace}" \
              --argjson generation "$GENERATION" \
              --arg timestamp "$TIMESTAMP" \
              --argjson aspects "$ASPECTS" \
              '{
                namespace: $namespace,
                generation: $generation,
                timestamp: $timestamp,
                aspects: $aspects
              }' > "$CTX_DIR/manifest.json"
          '';

        # --- dependency-map.md generator ---
        # Summarizes flake.lock into a human/AI-readable markdown table.
        # Focuses on: input name, source type, URL/owner+repo, pinned rev.
        generateDependencyMap = pkgs.writeShellScript "gen-dependency-map" ''
          set -euo pipefail
          LOCK="${flakeRoot}/flake.lock"
          CTX_DIR="${modulesDir}/community/ocd/_context"
          mkdir -p "$CTX_DIR"

          if [ ! -f "$LOCK" ]; then
            echo "# Dependency Map" > "$CTX_DIR/dependency-map.md"
            echo "" >> "$CTX_DIR/dependency-map.md"
            echo "_No flake.lock found. Run \`nix flake lock\` first._" >> "$CTX_DIR/dependency-map.md"
            exit 0
          fi

          {
            echo "# Dependency Map"
            echo ""
            echo "_Auto-generated from \`flake.lock\`. Do not edit — regenerate via context-engine._"
            echo ""
            echo "| Input | Type | Source | Rev (short) |"
            echo "|---|---|---|---|"
            ${pkgs.jq}/bin/jq -r '
              .nodes | to_entries[]
              | select(.key != "root")
              | .value.locked as $l
              | "| \(.key) | \($l.type // "?") | \(
                  if $l.type == "github" then "\($l.owner)/\($l.repo)"
                  elif $l.type == "path" then $l.path
                  else ($l.url // "?")
                  end
                ) | \($l.rev // $l.narHash // "?" | .[0:12]) |"
            ' "$LOCK"
          } > "$CTX_DIR/dependency-map.md"
        '';

        # --- Combined activation script ---
        regenerateContext = pkgs.writeShellScript "regenerate-context" ''
          set -euo pipefail
          echo "Layer 0: regenerating _context/ artifacts..."
          ${builtins.concatStringsSep "\n" (map (ns: "${generateManifest ns}") namespaces)}
          ${generateDependencyMap}
          echo "Layer 0: context regeneration complete."
        '';

      in
      {
        # Run context regeneration on every system activation.
        # This is the "rebuild → regenerate" step of the feedback loop.
        system.activationScripts.layer0-context = {
          text = "${regenerateContext}";
          # Run after other activation scripts so system state is settled.
          deps = [
            "etc"
            "users"
          ];
        };
      };

    # -- Home Manager class: expose context to OpenClaw tools --
    homeManager =
      { config, ... }:
      let
        # Well-known path where OpenClaw tools look for context.
        # This is a symlink farm pointing to the actual _context/ dirs
        # so OpenClaw doesn't need to know the flake root path.
        contextHome = "${config.xdg.dataHome}/ocd-context";
      in
      {
        # Create symlinks so OpenClaw tools can find context at a stable path.
        # Example: ~/.local/share/ocd-context/community-ocd/ -> /etc/nixos/modules/community/ocd/_context/
        #
        # NOTE: This is a sketch. The actual implementation depends on:
        # - Whether the flake is deployed to /etc/nixos or another path
        # - Whether OpenClaw runs as the same user
        # - Whether we want to copy (immutable snapshot) or symlink (live)
        #
        # For now, this section is a placeholder documenting the intent.
        # OpenClaw plugin design should reference contextHome as the
        # well-known base path for context discovery.

        home.sessionVariables = {
          OCD_CONTEXT_HOME = contextHome;
        };
      };
  };
}

# --- FUTURE WORK (sub-concerns to explore) ---
#
# These are the Layer 0 sub-concerns identified at bootstrap. Each will need
# its own design phase before implementation. They are documented here so
# the context is preserved across sessions.
#
# 1. CONTEXT COMPRESSION
#    When the module tree grows large, manifest.json may exceed useful token
#    budgets. Strategies: hierarchical summaries (namespace-level → aspect-level),
#    relevance filtering (only include aspects related to the current task),
#    structured summarization (key facts per aspect, not full detail).
#    See: context-compression skill.
#
# 2. MEMORY SYSTEMS
#    OpenClaw needs cross-session memory: what it changed, what worked, what
#    broke, user preferences for modification style. Options: SQLite (OpenClaw
#    default), append-only change-log.md (simple), entity-aware knowledge graph
#    (rich but complex). The change-log.md is the minimum viable memory.
#    See: memory-systems skill.
#
# 3. MULTI-AGENT COORDINATION
#    If multiple OpenClaw instances or plugins modify aspects concurrently,
#    we need: generation-based conflict detection, namespace-scoped locking,
#    or optimistic concurrency with merge-on-conflict. The verification gate
#    (nix flake check + generation mismatch) provides basic safety.
#    See: multi-agent-patterns skill.
#
# 4. TOOL DESIGN REFINEMENT
#    The aspect-granular tool interface (list/read/write/validate/diff/record)
#    needs concrete MCP schema definitions, error handling patterns, and
#    integration with OpenClaw's plugin model. Should tools be an OpenClaw
#    bundled plugin, a custom plugin, or an MCP server?
#    See: tool-design skill.
#
# 5. CONTEXT DEGRADATION MONITORING
#    How to detect when context is not just stale but actively misleading:
#    manifest.json says an aspect exists but the file was deleted, dependency
#    map references an input that was removed, change-log records a
#    modification that was rolled back. Checksums? Nix hash comparison?
#    See: context-degradation skill.
#
# 6. FILESYSTEM-BASED CONTEXT OFFLOADING
#    For long-running agent sessions, offload intermediate reasoning to
#    scratch files (e.g. _context/scratch/) rather than holding everything
#    in the token window. The agent writes its analysis, reads it back
#    when needed, and cleans up on session end.
#    See: filesystem-context skill.
