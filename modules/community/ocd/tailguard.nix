# Tailscale exit node that routes through Cloudflare WARP via wgcf.
# Traffic from Tailscale clients is policy-routed through a WireGuard
# tunnel to Cloudflare, while the host's own traffic goes out normally.
#
# One-time setup:
#   wgcf register && wgcf generate
#   Encrypt PrivateKey with agenix → wg-warp-key.age
#   Set wg-warp IPs per-host from wgcf-profile.conf
#   tailscale set --advertise-exit-node
#   Approve exit node in Tailscale admin console
{ ... }:
let
  warpTable = 51820;
  warpMark = "0xca6c";
  warpMTU = 1220;
  warpMSS = 1180;
in
{
  ocd.tailguard.nixos =
    { config, pkgs, ... }:
    {
      networking.iproute2 = {
        enable = true;
        rttablesExtraConfig = "${toString warpTable} wg-warp";
      };

      networking.wireguard.interfaces.wg-warp = {
        # IPs set per-host from wgcf-profile.conf
        mtu = warpMTU;
        privateKeyFile = config.age.secrets.wg-warp-key.path;
        fwMark = warpMark;
        table = "${toString warpTable}";

        peers = [
          {
            publicKey = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
            allowedIPs = [
              "0.0.0.0/0"
            ];
            endpoint = "engage.cloudflareclient.com:2408";
            persistentKeepalive = 25;
            dynamicEndpointRefreshSeconds = 25;
          }
        ];

        postSetup = ''
          ${pkgs.iproute2}/bin/ip route replace default dev wg-warp table ${toString warpTable}
          ${pkgs.iproute2}/bin/ip rule add iif tailscale0 table ${toString warpTable} priority 100
          ${pkgs.iproute2}/bin/ip rule add fwmark ${warpMark} table main priority 90
          ${pkgs.iptables}/bin/iptables -t mangle -A FORWARD -o wg-warp \
            -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss ${toString warpMSS}
          ${pkgs.iptables}/bin/iptables -t mangle -A FORWARD -i wg-warp \
            -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss ${toString warpMSS}
        '';

        postShutdown = ''
          ${pkgs.iproute2}/bin/ip rule del iif tailscale0 table ${toString warpTable} priority 100 || true
          ${pkgs.iproute2}/bin/ip rule del fwmark ${warpMark} table main priority 90 || true
          ${pkgs.iproute2}/bin/ip route del default dev wg-warp table ${toString warpTable} || true
          ${pkgs.iptables}/bin/iptables -t mangle -D FORWARD -o wg-warp \
            -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss ${toString warpMSS} || true
          ${pkgs.iptables}/bin/iptables -t mangle -D FORWARD -i wg-warp \
            -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss ${toString warpMSS} || true
        '';
      };

      networking.nat = {
        enable = true;
        internalInterfaces = [ "tailscale0" ];
        externalInterface = "wg-warp";
      };

      services.tailscale.useRoutingFeatures = "both";
      networking.firewall.checkReversePath = "loose";
      networking.firewall.trustedInterfaces = [ "tailscale0" ];

      systemd.services.tailscaled = {
        after = [ "wireguard-wg-warp.service" ];
        wants = [ "wireguard-wg-warp.service" ];
      };

      environment.systemPackages = [ pkgs.wgcf ];
    };
}
