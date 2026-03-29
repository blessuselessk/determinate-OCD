{ ... }:
{
  ocd.cachix = {
    nixos = {
      nix.settings = {
        substituters = [ "https://determinate-ocd.cachix.org" ];
        trusted-public-keys = [
          "determinate-ocd.cachix.org-1:XlOTqDFmSf9HsbMmuhV/NexjPhcjFk0ogM1oMkgGGT0="
        ];
      };
    };
    darwin = {
      nix.settings = {
        substituters = [ "https://determinate-ocd.cachix.org" ];
        trusted-public-keys = [
          "determinate-ocd.cachix.org-1:XlOTqDFmSf9HsbMmuhV/NexjPhcjFk0ogM1oMkgGGT0="
        ];
      };
    };
  };
}
