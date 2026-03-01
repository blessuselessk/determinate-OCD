# Extract aspect descriptions and render through promptyst.
# Also generates .ai/AGENTS.md (hybrid: header + generated composability section),
# per-primitive-directory AGENTS.md files, rendered PROSE primitives, and ref pointers.
#
# Environment:
#   DESCRIPTIONS_DIR — nix store path containing *.toml / *.yaml aspect descriptions
#   PROSE_AGENTS_DIR — nix store path containing *.agent.toml PROSE sources
#   PROSE_INSTRUCTIONS_DIR — nix store path containing *.instructions.toml PROSE sources
#   PROSE_SKILLS_DIR — nix store path containing */SKILL.toml PROSE sources
#   PROSE_WORKFLOWS_DIR — nix store path containing *.workflow.toml PROSE sources
#   PROSE_RENDER_TEMPLATE — path to render-prose.typ template
#   RENDER_TEMPLATE — path to the render-aspect.typ template
#   AGENTS_TEMPLATE — path to the render-agents-md.typ template
#   PRIMITIVE_AGENTS_TEMPLATE — path to the render-primitive-agents-md.typ template
#   PROMPTYST_PACKAGE_PATH — linkFarm path for @local/promptyst:0.2.0
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

# ── Per-primitive AGENTS.md files ──

let primitive_dirs = {
  agent: "agents",
  instruction: "instructions",
  prompt: "prompts",
  context: "context",
  memory: "memory",
  spec: "specs",
  skill: "skills",
}

for entry in ($primitive_dirs | transpose key value) {
  let prim = $entry.key
  let dir = $entry.value

  let prim_md = (
    typst query
      --root .
      $env.PRIMITIVE_AGENTS_TEMPLATE
      "<output>"
      --field value
      --one
      --input $"schema-path=($staged_schema)"
      --input $"primitive=($prim)"
    | from json
  )

  mkdir $"($out)/primitive-agents/($dir)"
  $prim_md | save $"($out)/primitive-agents/($dir)/AGENTS.md"
  print $"Rendered ($out)/primitive-agents/($dir)/AGENTS.md"
}

# ── Render PROSE primitives + generate ref pointers ──

# Helper: render and generate ref for a single TOML source
def render-prose [file: string, prim_type: string, out_dir: string, top_key: string, id_field: string, ref_type: string] {
  let out = $env.out

  # Stage TOML into working directory for Typst.
  # Use parent dir name as prefix for skills (all named SKILL.toml).
  let filename = ($file | path basename)
  let staged_name = if $prim_type == "skill" {
    let parent = ($file | path dirname | path basename)
    $"($parent)-($filename)"
  } else {
    $filename
  }
  let staged = $"./($staged_name)"
  open $file --raw | save -f $staged

  # Render through render-prose.typ
  let md = (
    TYPST_PACKAGE_PATH=$env.PROMPTYST_PACKAGE_PATH
    typst query
      --root .
      $env.PROSE_RENDER_TEMPLATE
      "<output>"
      --field value
      --one
      --input $"src=($staged)"
    | from json
  )

  # Parse TOML for metadata
  let data = (open $file --raw | from toml)
  let meta = ($data | get $top_key)
  let id = ($meta | get $id_field)

  # Write rendered Markdown
  if $prim_type == "skill" {
    let skill_out = $"($out)/prose/skills/($id)"
    mkdir $skill_out
    $md | save $"($skill_out)/SKILL.md"
    print $"Rendered ($skill_out)/SKILL.md"
  } else {
    let type_out = $"($out)/prose/($out_dir)"
    mkdir $type_out
    $md | save $"($type_out)/($id).($prim_type).md"
    print $"Rendered ($type_out)/($id).($prim_type).md"
  }

  # Generate ref pointer for .github/
  let canonical_path = if $prim_type == "skill" {
    $"../../.ai/skills/($id)/SKILL.md"
  } else {
    $"../../.ai/($out_dir)/($id).($prim_type).md"
  }

  let frontmatter = if $prim_type == "agent" {
    let tools_list = ($meta | get tools | each {|t| $"'($t)'" } | str join ", ")
    $"---\ndescription: \"($meta.description)\"\ntools: [($tools_list)]\n---"
  } else if $prim_type == "instructions" {
    let apply_to = ($meta | get apply-to)
    $"---\napplyTo: \"($apply_to)\"\ndescription: \"($meta.description)\"\n---"
  } else if $prim_type == "skill" {
    $"---\nname: \"($meta.name)\"\ndescription: \"($meta.description)\"\n---"
  } else if $prim_type == "workflow" {
    $"---\ndescription: \"($meta.description)\"\nmode: \"($meta.mode)\"\n---"
  } else {
    $"---\ndescription: \"($meta.description)\"\n---"
  }

  let ref_name = $"($id).ref.($ref_type).md"

  let ref_md = ([
    "<!-- generated — do not edit -->"
    $frontmatter
    ""
    $"Refer to [($id)]\(($canonical_path)\) for the full ($ref_type) definition."
    ""
  ] | str join "\n")

  let ref_out = $"($out)/refs/($out_dir)"
  mkdir $ref_out
  $ref_md | save $"($ref_out)/($ref_name)"
  print $"Generated ($ref_out)/($ref_name)"
}

# Agents
for file in (glob $"($env.PROSE_AGENTS_DIR)/*.agent.toml") {
  render-prose $file "agent" "agents" "agent" "id" "agent"
}

# Instructions
for file in (glob $"($env.PROSE_INSTRUCTIONS_DIR)/*.instructions.toml") {
  render-prose $file "instructions" "instructions" "instruction" "id" "instructions"
}

# Skills
for file in (glob $"($env.PROSE_SKILLS_DIR)/*/SKILL.toml") {
  render-prose $file "skill" "skills" "skill" "name" "skill"
}

# Workflows
for file in (glob $"($env.PROSE_WORKFLOWS_DIR)/*.workflow.toml") {
  render-prose $file "workflow" "workflows" "workflow" "id" "workflow"
}
