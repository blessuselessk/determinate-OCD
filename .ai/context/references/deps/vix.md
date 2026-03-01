# vix

> Vic's Nix Environment. A dendritic configuration providing reusable aspects for NixOS hosts.

Source: `github:vic/vix`

### Configure Host Features with Vix Modules (Nix)

Source: https://context7.com/vic/vix/llms.txt

Configures host-specific features by including reusable modules from the vix namespace. This example for the 'nargun' host includes modules for bootable systems, desktop environments, networking, and system essentials.

```nix
# modules/hosts/nargun/features.nix
{
  vix,
  den,
  ...
}:
let
  features = with vix;
    [
      bootable
      mexico
      niri-desktop
      xfce-desktop
      gnome-desktop
      bluetooth
      hw-detect
      hostname
      macos-keys
      networking
      vix.system'
    ];
in
{
  den.aspects.nargun.includes = features;
}
```

______________________________________________________________________

### Define NixOS Host Configuration with Users (Nix)

Source: https://context7.com/vic/vix/llms.txt

Defines NixOS hosts and their associated users using the den.hosts option structure. This snippet sets up a host named 'nargun' for the 'vic' user on an x86_64-linux architecture.

```nix
# modules/hosts.nix
{
  den.hosts.x86_64-linux.nargun.users.vic = { };
}
```

______________________________________________________________________

### Define User Environment with Home Manager

Source: https://context7.com/vic/vix/llms.txt

Sets up the user environment for 'vic' across all hosts using Home Manager, including essential user shells and autologin features.

```nix
# modules/users/vic/everywhere.nix
{ vix, vic, den, inputs, ... }:
let
  everywhere.description = ''
    This aspect is vic's user base environment
    on every host where vic exists.
  '';

  everywhere.__functor = den.lib.parametric;
  everywhere.includes = [
    den.provides.primary-user
    (den.provides.user-shell "fish")
    (vix.autologin)
    (vix.nix-index)
    (vix.nix-registry)
    (vix.macos-keys)
  ];
in
{
  vic = { inherit everywhere; };

  den.aspects.vic.includes = [ vic.everywhere ];
  den.aspects.vic.user.description = "El Oeiuwq";

  den.aspects.nargun.includes = [
    (den.provides.unfree [ "vscode" ])
  ];
}
```

### vix - Vic's Nix Environment > Hosts

Source: https://github.com/vic/vix/blob/unflake/README.md

The 'Hosts' section defines the different machines managed by this Nix environment. Configurations for these hosts are located in `modules/hosts.nix`. Currently, only the `nargun` host is configured, with plans to port other hosts soon. This modular approach allows for specific configurations tailored to each host.

______________________________________________________________________

### Vix > Host Configuration

Source: https://context7.com/vic/vix/llms.txt

Define NixOS hosts with their architecture and associated users using the `den.hosts` option structure.
