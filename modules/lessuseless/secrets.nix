{ ... }:
{
  lessuseless.secrets.darwin =
    { config, ... }:
    {
      age.secrets.openclaw-gateway-token.file = ./secrets/openclaw-gateway-token.age;
      age.secrets.minimax-api-key.file = ./secrets/minimax-api-key.age;

      # Inject secrets into GUI environment (desktop apps read these via launchctl)
      launchd.agents.openclaw-secrets = {
        serviceConfig = {
          ProgramArguments = [
            "/bin/sh"
            "-c"
            ''
              # Gateway token
              if [ -r "${config.age.secrets.openclaw-gateway-token.path}" ]; then
                launchctl setenv OPENCLAW_GATEWAY_TOKEN "$(cat "${config.age.secrets.openclaw-gateway-token.path}")"
              elif [ -r "$HOME/.openclaw/.env" ]; then
                launchctl setenv OPENCLAW_GATEWAY_TOKEN "$(grep OPENCLAW_GATEWAY_TOKEN "$HOME/.openclaw/.env" | cut -d= -f2)"
              fi
              # MiniMax API key (GLM fallback)
              if [ -r "${config.age.secrets.minimax-api-key.path}" ]; then
                launchctl setenv MINIMAX_API_KEY "$(cat "${config.age.secrets.minimax-api-key.path}")"
              fi
            ''
          ];
          RunAtLoad = true;
        };
      };
    };
}
