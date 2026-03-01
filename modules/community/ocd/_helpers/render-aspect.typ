// Renders a single aspect description to Markdown via promptyst.
// Called via: typst query --input data-path=<path> --input format=<toml|yaml> render-aspect.typ "<output>"

#import "@local/promptyst:0.1.0": from-toml, from-yaml, render-prompt, render-context, render-schema

#let format = sys.inputs.at("format", default: "toml")
#let data-path = sys.inputs.at("data-path", default: sys.inputs.at("toml-path", default: none))
#let raw = read(data-path)
#let result = if format == "yaml" { from-yaml(raw) } else { from-toml(raw) }

#let md = if result.at("prompt", default: none) != none {
  render-prompt(result.prompt)
} else if result.at("context", default: none) != none {
  render-context(result.context)
} else if result.at("schema", default: none) != none {
  render-schema(result.schema)
} else {
  "# " + result.at("aspect", default: (id: "unknown")).at("id", default: "unknown")
}

#metadata(md) <output>
