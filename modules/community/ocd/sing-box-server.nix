# VLESS+Reality proxy server for bypassing hostile networks (Fortinet, etc).
# Listens on TCP 443 disguised as normal HTTPS traffic.
# Client connects from mclovin to tunnel Tailscale through this.
{ ... }:
{
  ocd.sing-box-server.nixos =
    { ... }:
    {
      services.sing-box = {
        enable = true;
        settings = {
          log.level = "info";
          inbounds = [
            {
              type = "vless";
              tag = "vless-in";
              listen = "::";
              listen_port = 443;
              users = [
                {
                  name = "mclovin";
                  uuid = "8eb08fc5-468d-4b4d-9cda-0df6965048f3";
                  flow = "xtls-rprx-vision";
                }
              ];
              tls = {
                enabled = true;
                server_name = "www.microsoft.com";
                reality = {
                  enabled = true;
                  handshake = {
                    server = "www.microsoft.com";
                    server_port = 443;
                  };
                  private_key = "CMT44yZQXRegmBwaMXxWCYp76MWo06FmnnKnPVND80M";
                  short_id = [ "f6b8152a08c83b8a" ];
                };
              };
            }
          ];
          outbounds = [
            {
              type = "direct";
              tag = "direct";
            }
          ];
        };
      };

      # Open TCP 443 in the NixOS firewall
      networking.firewall.allowedTCPPorts = [ 443 ];
    };
}
