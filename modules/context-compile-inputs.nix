{ lib, ... }:
{
  flake-file.inputs = {
    nuenv = {
      url = lib.mkDefault "github:xav-ie/nuenv";
    };
    promptyst = {
      url = lib.mkDefault "github:blessuselessk/promptyst";
      flake = lib.mkDefault false;
    };
  };
}
