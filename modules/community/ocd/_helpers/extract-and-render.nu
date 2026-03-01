# Extract aspect descriptions and render through promptyst.
#
# Environment:
#   DESCRIPTIONS_DIR — nix store path containing *.toml aspect descriptions
#   RENDER_TEMPLATE — path to the render-aspect.typ template
#   PROMPTYST_PACKAGE_PATH — linkFarm path for @local/promptyst:0.1.0

let out = $env.out
mkdir $out

let toml_files = (glob $"($env.DESCRIPTIONS_DIR)/*.toml")

for toml_file in $toml_files {
  let name = ($toml_file | path parse | get stem)

  # Stage TOML into working directory (within Typst's --root).
  # nuenv may have already copied it from src; if not, read from the store.
  let staged = $"./($name).toml"
  if not ($staged | path exists) {
    open $toml_file --raw | save $staged
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
      --input $"toml-path=($staged)"
    | from json
  )

  $md | save $"($out)/($name).md"
  open $staged --raw | save $"($out)/($name).toml"
  print $"Rendered ($out)/($name).md"
}
