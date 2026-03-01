// Renders a per-directory AGENTS.md for a single primitive type.
// Called via: typst query --input schema-path=<path> --input primitive=<name>
//             render-primitive-agents-md.typ "<output>"
//
// Produces a scoped AGENTS.md that agents discover via directory tree walk.

#let schema-path = sys.inputs.at("schema-path")
#let primitive-name = sys.inputs.at("primitive")
#let data = yaml(schema-path)

#let primitives = data.at("primitives")
#let edges = data.at("edges")
#let invalid = data.at("invalid")
#let tiers = data.at("tiers")

#let prim = primitives.at(primitive-name)

// ── helpers ──

#let join-list(items, sep: ", ") = {
  let out = ""
  for (i, item) in items.enumerate() {
    if i > 0 { out += sep }
    out += str(item)
  }
  out
}

// ── directory name mapping ──

#let dir-names = (
  "agent": "agents",
  "instruction": "instructions",
  "prompt": "prompts",
  "context": "context",
  "memory": "memory",
  "spec": "specs",
  "skill": "skills",
)

#let dir-name = dir-names.at(primitive-name)

// ── find tier info ──

#let tier-name = prim.at("tier")
#let tier = tiers.at(tier-name)

// ── render ──

#let md = {
  let out = "# " + dir-name + "/\n\n"
  out += "> " + prim.at("description").trim().replace("\n", " ") + "\n\n"

  // Tier + capabilities
  out += "## Tier: " + tier-name + "\n\n"
  out += "**Can**: " + join-list(tier.at("can")) + "\n\n"
  let cannot = tier.at("cannot", default: none)
  if cannot != none {
    out += "**Cannot**: " + join-list(cannot) + "\n\n"
  }

  // File pattern
  out += "## File Pattern\n\n"
  out += "`" + prim.at("file_pattern") + "`\n\n"

  // Frontmatter
  let fm = prim.at("frontmatter", default: none)
  if fm != none {
    let req = fm.at("required", default: ())
    let opt = fm.at("optional", default: ())
    if req.len() > 0 or opt.len() > 0 {
      out += "## Frontmatter\n\n"
      if req.len() > 0 {
        out += "**Required**: `" + join-list(req, sep: "`, `") + "`\n\n"
      }
      if opt.len() > 0 {
        out += "**Optional**: `" + join-list(opt, sep: "`, `") + "`\n\n"
      }
    }
  }

  // Outbound edges
  let outbound = edges.filter(e => e.at("from") == primitive-name)
  if outbound.len() > 0 {
    out += "## Outbound Edges\n\n"
    for edge in outbound {
      out += "- → **" + str(edge.at("to")) + "**: "
      out += edge.at("verb") + " (" + edge.at("direction") + ")"
      let note = edge.at("note", default: none)
      if note != none {
        out += " — " + note.trim().replace("\n", " ")
      }
      out += "\n"
    }
    out += "\n"
  }

  // Inbound edges
  let inbound = edges.filter(e => {
    let target = str(e.at("to")).replace(" (other)", "")
    target == primitive-name
  })
  if inbound.len() > 0 {
    out += "## Inbound Edges\n\n"
    for edge in inbound {
      out += "- ← **" + edge.at("from") + "**: "
      out += edge.at("verb") + " (" + edge.at("direction") + ")"
      out += "\n"
    }
    out += "\n"
  }

  // Invalid edges involving this primitive
  let invalid-from = invalid.filter(r => r.at("from") == primitive-name)
  let invalid-to = invalid.filter(r => {
    let targets = r.at("to")
    if type(targets) == array { primitive-name in targets }
    else { str(targets) == primitive-name }
  })
  if invalid-from.len() > 0 or invalid-to.len() > 0 {
    out += "## Prohibited\n\n"
    for rule in invalid-from {
      let targets = if type(rule.at("to")) == array {
        join-list(rule.at("to"))
      } else { str(rule.at("to")) }
      out += "- Cannot **" + rule.at("verb") + "** " + targets + ": "
      out += rule.at("reason").trim().replace("\n", " ") + "\n"
    }
    for rule in invalid-to {
      out += "- **" + rule.at("from") + "** cannot **" + rule.at("verb") + "** this: "
      out += rule.at("reason").trim().replace("\n", " ") + "\n"
    }
    out += "\n"
  }

  out
}

#metadata(md) <output>
