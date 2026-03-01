// Renders a single aspect TOML to Markdown via promptyst.
// Called via: typst query --input toml-path=<path> render-aspect.typ "<output>"

#import "@local/promptyst:0.1.0": from-toml, render-prompt, render-context, render-schema

#let toml-path = sys.inputs.at("toml-path")
#let raw = read(toml-path)
#let result = from-toml(raw)

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
