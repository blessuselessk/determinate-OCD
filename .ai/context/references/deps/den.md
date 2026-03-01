# den

> Context-aware framework for building modular Nix configurations for NixOS, nix-darwin, and home-manager using declarative dendritic libraries.

Source: `github:vic/den`

### Reading Aspects from Namespaces

Source: https://github.com/vic/den/wiki/namespaces

This code illustrates how to read aspects from a namespace. The namespace is typically passed as an argument to the module. You can then access its aspects, for example, `vix.security`, and include them in other configurations like `den.default.includes`.

```nix
# Access the namespace from module args
{ vix, ... }:
{
  den.default.includes = [ vix.security ];
}
```

______________________________________________________________________

### Including Aspects with includes in Nix

Source: https://context7.com/vic/den/llms.txt

Demonstrates composing aspects by including other aspects. Includes can be static aspects, parametric functions, exact matches, or references to other aspects and batteries.

```nix
{ den, lib, ... }: {
  den.aspects.igloo.includes = [
    # Static include - always active
    { nixos.programs.vim.enable = true; }

    # Function include - runs when context matches { host, ... }
    ({ host, ... }: {
      nixos.time.timeZone = "UTC";
    })

    # Exactly match - only runs with { host }, not { host, user }
    (den.lib.take.exactly ({ host }: {
      nixos.networking.hostName = host.hostName;
    }))

    # Reference to another aspect
    den.aspects.tools._.editors

    # Reference to a battery
    den.provides.primary-user
  ];
}
```

______________________________________________________________________

### Accessing Deeply Nested Aspects with Angle Brackets

Source: https://github.com/vic/den/wiki/namespaces

This example showcases the use of Den's angle-bracket syntax for accessing deeply nested aspect trees within a namespace. Instead of the full `den.ful.<namespace>.<aspect>` path, you can use a more concise notation like `<vix/gaming/retro>` to reference aspects, improving readability.

```nix
{ __findFile, ... }:
  den.aspects.my-laptop.includes = [ 
    <vix/gaming/retro> 
    
    # instead of den.ful.vix.gaming.provides.retro
  ];
```

### Namespaces for Sharing Aspects

Source: https://context7.com/vic/den/llms.txt

Namespaces in Den allow you to share aspects across different repositories or projects. By importing Den with a specific namespace using `inputs.den.namespace`, you can create a distinct scope for your aspects. Aspects defined within this namespace, like `ns.tools.nixos.programs.vim.enable`, can then be included in other configurations, such as `den.aspects.igloo.includes`. This promotes reusability and modularity, enabling you to manage and share common configuration components effectively across multiple Den projects.

______________________________________________________________________

### den.aspects Reference > den.aspects (namespace)

Source: https://github.com/vic/den/blob/main/docs/src/content/docs/reference/aspects.mdx

The `den.aspects` namespace is the designated area where Den automatically creates aspects for your hosts, users, and homes. You can also leverage this namespace to define and manage your own custom aspects. Importantly, aspects defined within `den.aspects` are local to the flake and are not exposed externally. For aspects intended for sharing across flakes, you should use the `den.namespace` instead. Contributions from various modules within this namespace are merged together, allowing for modular configuration. For example, settings for `networking.hostName` and `programs.vim.enable` can be defined in separate files and will be combined under the `den.aspects.igloo` aspect.
