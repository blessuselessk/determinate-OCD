{ ... }:
{
  lessuseless.secrets.darwin =
    { config, ... }:
    {
      age.secrets.openclaw-gateway-token.file = ./secrets/openclaw-gateway-token.age;

      # Inject OPENCLAW_GATEWAY_TOKEN into GUI environment (desktop app reads this)
      launchd.agents.openclaw-gateway-token = {
        serviceConfig = {
          ProgramArguments = [
            "/bin/sh"
            "-c"
            ''launchctl setenv OPENCLAW_GATEWAY_TOKEN "$(cat ${config.age.secrets.openclaw-gateway-token.path})"''
          ];
          RunAtLoad = true;
        };
      };
    };
}
