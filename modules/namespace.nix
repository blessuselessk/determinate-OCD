{ inputs, den, ... }:
{
  _module.args.__findFile = den.lib.__findFile;
  imports = [
    (inputs.den.namespace "ocd" true) # community — exposed at flake.denful.ocd
    (inputs.den.namespace "lessuseless" false) # personal
  ];
}
