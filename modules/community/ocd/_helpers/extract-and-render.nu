# Extract aspect descriptions and render through promptyst.
#
# Environment:
#   ASPECT_NAMES — space-separated list of aspect names
#   ASPECT_<UPPER_NAME> — TOML content for each aspect
#   RENDER_TEMPLATE — path to the render-aspect.typ template
#   PROMPTYST_PACKAGE_PATH — linkFarm path for @local/promptyst:0.1.0

let out = $env.out
mkdir $out

let names = ($env.ASPECT_NAMES | split row " " | where {|it| ($it | str trim | str length) > 0 })

for name in $names {
  let env_key = ($name | str upcase | str replace --all '.' '_' | str replace --all '-' '_')
  let toml_content = ($env | get $"ASPECT_($env_key)" | str trim)

  if ($toml_content | str length) == 0 {
    print $"Skipping ($name): empty description"
    continue
  }

  # Write staged TOML to working directory (within Typst's --root)
  let toml_file = $"./($name).toml"
  $toml_content | save $toml_file

  # Render through promptyst via typst query
  let md = (
    TYPST_PACKAGE_PATH=$env.PROMPTYST_PACKAGE_PATH
    typst query
      --root .
      $env.RENDER_TEMPLATE
      "<output>"
      --field value
      --one
      --input $"toml-path=($toml_file)"
    | from json
  )

  $md | save $"($out)/($name).md"
  cp $toml_file $"($out)/($name).toml"
  print $"Rendered ($out)/($name).md"
}
