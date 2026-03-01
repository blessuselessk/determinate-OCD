# Extract aspect descriptions and render through promptyst.
# Also generates .ai/AGENTS.md (hybrid: header + generated composability section).
#
# Environment:
#   DESCRIPTIONS_DIR — nix store path containing *.toml / *.yaml aspect descriptions
#   RENDER_TEMPLATE — path to the render-aspect.typ template
#   AGENTS_TEMPLATE — path to the render-agents-md.typ template
#   PROMPTYST_PACKAGE_PATH — linkFarm path for @local/promptyst:0.1.0
#   COMPOSABILITY_SCHEMA — nix store path to primitive-composability-schema.yaml
#   AGENTS_HEADER — nix store path to AGENTS.md.header

let out = $env.out
mkdir $out

# ── Aspect descriptions ──

let desc_files = (
  (glob $"($env.DESCRIPTIONS_DIR)/*.toml" | each {|f| {file: $f, format: "toml"}})
  | append (glob $"($env.DESCRIPTIONS_DIR)/*.yaml" | each {|f| {file: $f, format: "yaml"}})
)

for entry in $desc_files {
  let file = $entry.file
  let format = $entry.format
  let name = ($file | path parse | get stem)

  # Stage file into working directory (within Typst's --root).
  # nuenv may have already copied it from src; if not, read from the store.
  let staged = $"./($name).($format)"
  if not ($staged | path exists) {
    open $file --raw | save $staged
  }

  # Render through promptyst via typst query
  let md = (
    TYPST_PACKAGE_PATH=$env.PROMPTYST_PACKAGE_PATH
    typst query
      --root .
      $env.RENDER_TEMPLATE
      "<output>"
      --field value
      --one
      --input $"data-path=($staged)"
      --input $"format=($format)"
    | from json
  )

  $md | save $"($out)/($name).md"
  open $staged --raw | save $"($out)/($name).($format)"
  print $"Rendered ($out)/($name).md"
}

# ── AGENTS.md (hybrid: header + generated composability) ──

let schema_path = $env.COMPOSABILITY_SCHEMA
let staged_schema = "./primitive-composability-schema.yaml"
if not ($staged_schema | path exists) {
  open $schema_path --raw | save $staged_schema
}

let generated = (
  typst query
    --root .
    $env.AGENTS_TEMPLATE
    "<output>"
    --field value
    --one
    --input $"schema-path=($staged_schema)"
  | from json
)

# Assemble hybrid: hand-authored header + generated composability section
let header = (open $env.AGENTS_HEADER --raw)
let agents_md = $"($header)\n($generated)\n<!-- END GENERATED SECTION -->\n"

$agents_md | save $"($out)/AGENTS.md"
print $"Rendered ($out)/AGENTS.md"
