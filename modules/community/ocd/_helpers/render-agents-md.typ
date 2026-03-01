// Renders .ai/AGENTS.md from the primitive composability schema.
// Called via: typst query --input schema-path=<path> render-agents-md.typ "<output>"
//
// Reads the composability schema YAML directly (not through promptyst ingestion)
// and renders a structured Markdown document suitable as .ai/AGENTS.md.

#let schema-path = sys.inputs.at("schema-path")
#let data = yaml(schema-path)

#let primitives = data.at("primitives")
#let edges = data.at("edges")
#let invalid = data.at("invalid")
#let tiers = data.at("tiers")
#let loops = data.at("feedback_loops")

// ── helpers ──

#let join-list(items, sep: ", ") = {
  let out = ""
  for (i, item) in items.enumerate() {
    if i > 0 { out += sep }
    out += str(item)
  }
  out
}

#let md-table-row(cells) = {
  "| " + cells.join(" | ") + " |"
}

// ── render ──

#let md = {
  let out = "# Agent Primitives\n\n"
  out += "Composability rules for PROSE agent primitives.\n"
  out += "Source: `.ai/context/primitive-composability-schema.yaml`\n\n"

  // ── Tier overview ──
  out += "## Tiers\n\n"
  out += md-table-row(("Tier", "Members", "Can", "Cannot")) + "\n"
  out += "| --- | --- | --- | --- |\n"
  for (tier-name, tier) in tiers.pairs() {
    let members = join-list(tier.at("members"))
    let can = join-list(tier.at("can"))
    let cannot = if tier.at("cannot", default: none) != none {
      join-list(tier.at("cannot"))
    } else { "—" }
    out += md-table-row((tier-name, members, can, cannot)) + "\n"
  }
  out += "\n"
  for (tier-name, tier) in tiers.pairs() {
    let note = tier.at("note", default: none)
    if note != none {
      out += "**" + tier-name + "**: " + note.trim() + "\n\n"
    }
  }

  // ── Primitive definitions ──
  out += "## Primitives\n\n"
  out += md-table-row(("Primitive", "File pattern", "Tier", "Description")) + "\n"
  out += "| --- | --- | --- | --- |\n"
  for (name, prim) in primitives.pairs() {
    let desc = prim.at("description").trim().replace("\n", " ")
    let pattern = "`" + prim.at("file_pattern") + "`"
    out += md-table-row((name, pattern, prim.at("tier"), desc)) + "\n"
  }
  out += "\n"

  // ── Frontmatter reference ──
  out += "### Frontmatter\n\n"
  for (name, prim) in primitives.pairs() {
    let fm = prim.at("frontmatter", default: none)
    if fm != none {
      let req = fm.at("required", default: ())
      let opt = fm.at("optional", default: ())
      if req.len() > 0 or opt.len() > 0 {
        out += "**" + name + "**: "
        if req.len() > 0 {
          out += "required(`" + join-list(req, sep: "`, `") + "`)"
        }
        if req.len() > 0 and opt.len() > 0 { out += " " }
        if opt.len() > 0 {
          out += "optional(`" + join-list(opt, sep: "`, `") + "`)"
        }
        out += "\n\n"
      }
    }
  }

  // ── Valid edges ──
  out += "## Valid Edges\n\n"
  out += md-table-row(("From", "To", "Verb", "Mechanism", "Direction")) + "\n"
  out += "| --- | --- | --- | --- | --- |\n"
  for edge in edges {
    out += md-table-row((
      edge.at("from"),
      str(edge.at("to")),
      edge.at("verb"),
      edge.at("mechanism"),
      edge.at("direction"),
    )) + "\n"
  }
  out += "\n"

  // ── Composability matrix ──
  out += "## Composability Matrix\n\n"
  // Build lookup: (from, to) → list of codes
  let code-map = (
    "invoke": "I",
    "auto-load": "AL",
    "reference": "R",
    "produce": "P",
  )
  let verb-override = (
    "hands-off-to": "H",
    "spawns": "S",
    "chains-to": "C",
  )
  let prim-names = primitives.keys()
  // Use short labels for the matrix
  let short-labels = (
    "agent": "agent",
    "instruction": "instr",
    "prompt": "prompt",
    "context": "context",
    "memory": "memory",
    "spec": "spec",
    "skill": "skill",
    "agents_md": "agents.md",
  )
  let col-w = 10
  let row-w = 12
  // Header
  out += "```\n"
  out += " " * row-w + "TO →\n"
  out += "FROM ↓" + " " * (row-w - 6)
  for name in prim-names {
    let label = short-labels.at(name, default: name)
    let padded = label
    while padded.len() < col-w { padded += " " }
    out += padded
  }
  out += "\n"
  out += "─" * (row-w + prim-names.len() * col-w) + "\n"
  // Rows
  for from-name in prim-names {
    let label = short-labels.at(from-name, default: from-name)
    let padded = label
    while padded.len() < row-w { padded += " " }
    out += padded
    for to-name in prim-names {
      let codes = ()
      for edge in edges {
        let edge-to = str(edge.at("to")).replace(" (other)", "")
        if edge.at("from") == from-name and edge-to == to-name {
          let code = verb-override.at(edge.at("verb"), default:
            code-map.at(edge.at("direction"), default: "?"))
          if code not in codes { codes.push(code) }
        }
      }
      let cell = if codes.len() > 0 { join-list(codes, sep: ",") } else { "·" }
      let cell-padded = cell
      while cell-padded.len() < col-w { cell-padded += " " }
      out += cell-padded
    }
    out += "\n"
  }
  out += "```\n\n"
  out += "**I**=invokes **H**=hands-off **S**=spawns **AL**=auto-loads "
  out += "**R**=references **P**=produces **C**=chains-to **·**=invalid\n\n"

  // ── Invalid edges ──
  out += "## Invalid Edges\n\n"
  for rule in invalid {
    let targets = if type(rule.at("to")) == array {
      join-list(rule.at("to"))
    } else { str(rule.at("to")) }
    out += "- **" + rule.at("from") + "** cannot " + rule.at("verb") + " **" + targets + "**: "
    out += rule.at("reason").trim().replace("\n", " ") + "\n"
  }
  out += "\n"

  // ── Feedback loops ──
  out += "## Feedback Loops\n\n"
  for loop in loops {
    out += "**" + loop.at("name") + "** (`" + loop.at("path") + "`): "
    out += loop.at("description").trim().replace("\n", " ") + "\n\n"
  }

  out
}

#metadata(md) <output>
