// render-prose.typ — renders a single PROSE TOML source to Markdown.
// Usage: typst query --input src=./file.toml render-prose.typ "<output>" --field value --one

#import "@local/promptyst:0.2.0": render-prose

#let src-path = sys.inputs.at("src")
#let raw = read(src-path)

#metadata(render-prose(raw)) <output>
