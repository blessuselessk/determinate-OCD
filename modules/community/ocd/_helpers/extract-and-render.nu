# Extract aspect descriptions and render through promptyst.
#
# Environment:
#   DESCRIPTIONS_DIR — nix store path containing *.toml / *.yaml aspect descriptions
#   RENDER_TEMPLATE — path to the render-aspect.typ template
#   PROMPTYST_PACKAGE_PATH — linkFarm path for @local/promptyst:0.1.0

let out = $env.out
mkdir $out

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
