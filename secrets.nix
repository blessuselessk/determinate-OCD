let
  lessuseless = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQnPq/vY1gN4IvQf6jBCu6jJWULmIVnKjKoxZxpxakO";
  fogell = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOkx6l1quddujjkKmDAZ3Bzs1esovbfzKpSut1MAcwFA";
in
{
  "modules/lessuseless/secrets/telegram-bot-token.age".publicKeys = [
    lessuseless
    fogell
  ];
  "modules/lessuseless/secrets/openclaw-gateway-token.age".publicKeys = [
    lessuseless
    fogell
  ];
  "modules/lessuseless/secrets/wg-warp-key.age".publicKeys = [
    lessuseless
    fogell
  ];
}
