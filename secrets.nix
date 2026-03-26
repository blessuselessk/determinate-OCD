let
  lessuseless = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQnPq/vY1gN4IvQf6jBCu6jJWULmIVnKjKoxZxpxakO";
  fogell = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPMeHFPLO6iEdATwGLtC3a71xnwnS59HFrQPgG2CfBRM";
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
  "modules/lessuseless/secrets/minimax-api-key.age".publicKeys = [
    lessuseless
    fogell
  ];
  "modules/lessuseless/secrets/discord-bot-token.age".publicKeys = [
    lessuseless
    fogell
  ];
}
