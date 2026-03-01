# Update dep reference files from Context7 API or GitHub README.
#
# Reads manifest.toml, fetches documentation for each dep, and writes
# structured .md files to the deps directory.
#
# Environment:
#   TARGET_DIR (optional) — project root, defaults to "."
#   CONTEXT7_API_KEY (optional) — API key for Context7; works without but rate-limited

let target = if ("TARGET_DIR" in ($env | columns)) and (not ($env.TARGET_DIR | is-empty)) {
  $env.TARGET_DIR
} else {
  "."
}

let deps_dir = ($target | path join ".ai" "context" "references" "deps")
let manifest_path = ($deps_dir | path join "manifest.toml")

if not ($manifest_path | path exists) {
  print $"ERROR: Manifest not found at ($manifest_path)"
  exit 1
}

let manifest = (open $manifest_path --raw | from toml)
let deps = ($manifest | get dep)

let context7_base = "https://context7.com/api/v2"

# Check if API key is available
let has_key = ("CONTEXT7_API_KEY" in ($env | columns)) and (not ($env.CONTEXT7_API_KEY | is-empty))

# Derive owner/repo from "github:owner/repo" format
def parse-github-repo [repo: string]: nothing -> record {
  let parts = ($repo | str replace "github:" "" | split row "/")
  { owner: ($parts | first), repo: ($parts | last) }
}

# Fetch documentation from Context7 API
def fetch-context7 [library_id: string, query: string]: nothing -> any {
  let base = "https://context7.com/api/v2"
  let api_key_available = ("CONTEXT7_API_KEY" in ($env | columns)) and (not ($env.CONTEXT7_API_KEY | is-empty))

  let url = $"($base)/context?libraryId=($library_id)&query=($query | url encode)&type=txt"

  try {
    let resp = if $api_key_available {
      http get --headers [Authorization $"Bearer ($env.CONTEXT7_API_KEY)"] $url
    } else {
      http get $url
    }
    $resp
  } catch {|e|
    print $"  WARN: Context7 API failed for ($library_id): ($e.msg)"
    null
  }
}

# Fetch README from GitHub
def fetch-github-readme [owner: string, repo: string]: nothing -> any {
  let url = $"https://raw.githubusercontent.com/($owner)/($repo)/HEAD/README.md"

  try {
    http get $url
  } catch {|e|
    # Try main branch
    try {
      http get $"https://raw.githubusercontent.com/($owner)/($repo)/main/README.md"
    } catch {|e2|
      print $"  WARN: GitHub README fetch failed for ($owner)/($repo): ($e2.msg)"
      null
    }
  }
}

# Format output markdown
def format-dep-md [name: string, description: string, repo: string, content: any]: nothing -> string {
  let header = ([
    $"# ($name)"
    ""
    $"> ($description)"
    ""
    $"Source: `($repo)`"
    ""
  ] | str join "\n")

  if ($content | is-empty) or ($content | describe) == "nothing" {
    $"($header)\n*No documentation available. Fetch manually or check the source repository.*\n"
  } else {
    $"($header)\n($content | str trim)\n"
  }
}

print $"Reading manifest: ($manifest_path)"
print $"Output directory: ($deps_dir)"
print $"Deps to process: ($deps | length)"
print ""

mkdir $deps_dir

mut success = 0
mut failed = 0

for dep in $deps {
  let name = $dep.name
  let repo = $dep.repo
  let query = $dep.query
  let description = $dep.description
  let has_context7 = ("context7" in ($dep | columns)) and (not ($dep.context7? | is-empty))

  print $"Processing ($name)..."

  let content = if $has_context7 {
    let c7_id = $dep.context7
    print $"  Fetching from Context7: ($c7_id)"
    let result = (fetch-context7 $c7_id $query)
    if ($result | is-empty) {
      # Fall back to GitHub README
      let parsed = (parse-github-repo $repo)
      print $"  Falling back to GitHub README: ($parsed.owner)/($parsed.repo)"
      fetch-github-readme $parsed.owner $parsed.repo
    } else {
      $result
    }
  } else {
    let parsed = (parse-github-repo $repo)
    print $"  Fetching GitHub README: ($parsed.owner)/($parsed.repo)"
    fetch-github-readme $parsed.owner $parsed.repo
  }

  let md = (format-dep-md $name $description $repo $content)
  let out_path = ($deps_dir | path join $"($name).md")
  $md | save -f $out_path
  print $"  Wrote ($out_path)"

  $success = $success + 1
}

print ""
print $"Done. ($success) deps processed, ($failed) failed."
