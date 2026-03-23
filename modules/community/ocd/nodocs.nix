{ ... }:
{
  # Disable options documentation generation.
  # Works around a string context bug in den's nixModule: den.lib, den.aspects,
  # and den.ctx are declared with types.raw, which causes the options.json
  # derivation to reference the flake -source store path without proper context.
  # If nix-collect-garbage prunes that path, the system can become unbootable.
  # Upstream: https://github.com/vic/den/issues/252
  ocd.nodocs = {
    nixos.documentation.enable = false;
    darwin.documentation.enable = false;
  };
}
