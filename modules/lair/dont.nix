# den-tools mashup: CLI tools that combine Nix with other ecosystems.
#
#   why (github:jamesbrink/why)
#     CLI that explains programming errors using a locally-embedded LLM.
#     Single binary (~680MB with model), fully offline, no API keys.
#     Parses stack traces for Python, Rust, JS, Go, Java, C++.
#     Modes: pipe, stream, watch (log monitoring), capture (auto-explain failures).
#     Syntax: why "error" | cmd 2>&1 | why | why --watch logfile | why --capture -- cmd
#
{ ... }:
{
  lair.dont = { };
}
