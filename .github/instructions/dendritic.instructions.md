______________________________________________________________________

## applyTo: "modules/\*\*/\*.nix" description: "Dendritic pattern rules for aspect files"

# Dendritic Aspect Rules

Every `.nix` file under `modules/` follows the Dendritic pattern (mightyiam/dendritic).

## Structure

Each file is exactly one flake-parts module implementing one aspect:

```nix
# When using den (named aspects):
{ ocd, ... }: {
  ocd.networking.nixos = { lib, ... }: {
    networking.networkmanager.enable = true;
    networking.firewall.allowedTCPPorts = [ 443 22 ];
  };
}

# When using raw flake-parts:
{
  flake.modules.nixos.networking = { lib, ... }: {
    networking.networkmanager.enable = true;
  };
}
```

## Rules

- **One aspect per file.** No multi-aspect files.
- **Filename = aspect name.** Not the host or class name.
- **Multi-class is fine.** A single aspect can set `.nixos`, `.homeManager`, `.darwin`, etc.
- **No `specialArgs`.** Use `let` bindings or module options to share values.
- **No `default.nix`** under `modules/`. The Dendritic pattern classifies these as entry points, not aspects.

## Composition (den)

Aspects compose via `includes` lists and `provides` sub-aspects:

```nix
# Composing aspects
ocd.dev-workstation = {
  includes = [ ocd.networking  ocd.gateway  ocd.ssh ];
  nixos = { security.rtkit.enable = true; };
};

# Sub-aspects via provides
<infra>.workstation.provides = {
  hw.includes = [ <ocd.bootloader> ];
  vm.includes = [ <ocd.installer> ];
};
```

Angle-bracket syntax: `<namespace.aspect>` resolves via `den.lib.__findFile`. Dots separate namespace from aspect. Slashes traverse into `provides` (e.g. `<<infra>.workstation/hw>`).

## Naming

- Community aspects: `ocd.<aspect-name>` (e.g. `ocd.networking`)
- User aspects: `<user>.<aspect-name>` (e.g. `vic.shell`)
- Infra aspects: `<infra>.<aspect-name>` (e.g. `my.hosts`)

## Tooling

- **Formatting**: `nixfmt` (RFC-style). Run `treefmt` before committing.
- **Dead code**: Run `deadnix` to detect unused bindings. Remove them; don't comment them out.
- **Imports**: Never add manual imports. `import-tree` handles discovery. If you need a helper, put it in `_helpers/` and import explicitly within the aspect that uses it.
- **Comments**: Only where the logic isn't self-evident. Don't add docstrings to every option.
- **Validation**: Run `nix flake check` after creating or modifying any aspect.

## What NOT to do

- Don't put `default.nix` in `modules/`
- Don't use `specialArgs` or `extraSpecialArgs`
- Don't inline secrets — always use `config.age.secrets.<name>.path`
- Don't create files that configure multiple unrelated features
- Don't rely on import ordering — `import-tree` makes no ordering guarantees
- Don't use `private` in filenames for community aspects (blocks Dendrix sharing)
