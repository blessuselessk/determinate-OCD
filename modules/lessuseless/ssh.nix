{ ... }:
{
  lessuseless.ssh.homeManager = {
    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
      extraConfig = ''
        IdentityFile ~/.ssh/id_ed25519
        UseKeychain yes
      '';
    };
  };
}
