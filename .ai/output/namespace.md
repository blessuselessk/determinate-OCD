## Context: namespace-ctx
| Key | Value |
| --- | ----- |
| ocd-namespace | inputs.den.namespace "ocd" true — community namespace, exposed at flake.denful.ocd |
| lessuseless-namespace | inputs.den.namespace "lessuseless" false — personal namespace, local only |
| findFile | _module.args.__findFile = den.lib.__findFile — enables angle-bracket syntax (<ocd.aspect>) |
| pattern | Takes `inputs` and `den` arguments; sets _module.args then imports namespace declarations |