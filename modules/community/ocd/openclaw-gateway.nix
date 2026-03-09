# GP2 Gateway: OpenClaw as a NixOS system service.
# Secrets and channel config are wired per-host (see fogell.nix).
# For the client aspect, see openclaw.nix.
{ inputs, ... }:
{
  ocd.openclaw-gateway.nixos =
    { pkgs, ... }:
    let
      gatewayBase = inputs.nix-openclaw.packages.${pkgs.stdenv.hostPlatform.system}.openclaw-gateway;

      # Patch gateway JS to support v3 device auth payloads (platform + deviceFamily).
      # The macOS app (v2026.3.x) signs v3 payloads but this gateway version (v2026.2.25)
      # only verifies v2. Upstream main already has v3 support; this bridges the gap.
      # Remove this patch when updating nix-openclaw past v2026.2.25.
      v3PatchScript = pkgs.writeScript "patch-v3-device-auth" ''
        #!${pkgs.python3}/bin/python3
        """Patch openclaw-gateway JS bundles for v3 device auth payload support."""
        import sys, os, glob

        dist_dir = sys.argv[1]

        # --- Patch 1: buildDeviceAuthPayload function definition ---
        # Add v3 format support (platform + deviceFamily fields) alongside existing v2.
        old_fn = (
            "function buildDeviceAuthPayload(params) {\n"
            "\tconst scopes = params.scopes.join(\",\");\n"
            "\tconst token = params.token ?? \"\";\n"
            "\treturn [\n"
            "\t\t\"v2\",\n"
            "\t\tparams.deviceId,\n"
            "\t\tparams.clientId,\n"
            "\t\tparams.clientMode,\n"
            "\t\tparams.role,\n"
            "\t\tscopes,\n"
            "\t\tString(params.signedAtMs),\n"
            "\t\ttoken,\n"
            "\t\tparams.nonce\n"
            "\t].join(\"|\");\n"
            "}"
        )

        new_fn = (
            "function buildDeviceAuthPayload(params) {\n"
            "\tconst scopes = params.scopes.join(\",\");\n"
            "\tconst token = params.token ?? \"\";\n"
            "\tconst base = [params.deviceId, params.clientId, params.clientMode, "
            "params.role, scopes, String(params.signedAtMs), token, params.nonce];\n"
            "\tif (params.platform != null && params.deviceFamily != null) {\n"
            "\t\tconst norm = s => (s || \"\").trim().replace(/[A-Z]/g, "
            "c => c.toLowerCase());\n"
            "\t\treturn [\"v3\", ...base, norm(params.platform), "
            "norm(params.deviceFamily)].join(\"|\");\n"
            "\t}\n"
            "\treturn [\"v2\", ...base].join(\"|\");\n"
            "}"
        )

        patched_fn = 0
        for root, dirs, files in os.walk(dist_dir):
            for fname in files:
                if not fname.endswith(".js"):
                    continue
                fpath = os.path.join(root, fname)
                content = open(fpath).read()
                if old_fn in content:
                    content = content.replace(old_fn, new_fn)
                    open(fpath, "w").write(content)
                    patched_fn += 1
                    print(f"  Patched buildDeviceAuthPayload in {fname}")

        assert patched_fn > 0, "buildDeviceAuthPayload v2 not found in any JS file"
        print(f"  -> Patched function in {patched_fn} files")

        # --- Patch 2: verification call site in gateway-cli-*.js ---
        # Try v3 payload first, fall back to v2 for backward compatibility.
        T5 = "\t\t\t\t\t"
        T6 = "\t\t\t\t\t\t"

        old_verify = (
            f"{T5}const payload = buildDeviceAuthPayload({{\n"
            f"{T6}deviceId: device.id,\n"
            f"{T6}clientId: connectParams.client.id,\n"
            f"{T6}clientMode: connectParams.client.mode,\n"
            f"{T6}role,\n"
            f"{T6}scopes,\n"
            f"{T6}signedAtMs: signedAt,\n"
            f"{T6}token: connectParams.auth?.token ?? connectParams.auth?.deviceToken ?? null,\n"
            f"{T6}nonce: providedNonce\n"
            f"{T5}}});\n"
            f"{T5}const rejectDeviceSignatureInvalid = () => rejectDeviceAuthInvalid("
            "\"device-signature\", \"device signature invalid\");\n"
            f"{T5}if (!verifyDeviceSignature(device.publicKey, payload, device.signature)) {{"
        )

        new_verify = (
            f"{T5}const _payloadArgs = {{\n"
            f"{T6}deviceId: device.id,\n"
            f"{T6}clientId: connectParams.client.id,\n"
            f"{T6}clientMode: connectParams.client.mode,\n"
            f"{T6}role,\n"
            f"{T6}scopes,\n"
            f"{T6}signedAtMs: signedAt,\n"
            f"{T6}token: connectParams.auth?.token ?? connectParams.auth?.deviceToken ?? null,\n"
            f"{T6}nonce: providedNonce\n"
            f"{T5}}};\n"
            f"{T5}const _v3 = buildDeviceAuthPayload({{..._payloadArgs, "
            "platform: connectParams.client.platform, "
            "deviceFamily: connectParams.client.deviceFamily});\n"
            f"{T5}const _v2 = buildDeviceAuthPayload(_payloadArgs);\n"
            f"{T5}const payload = verifyDeviceSignature(device.publicKey, _v3, device.signature)"
            " ? _v3 : _v2;\n"
            f"{T5}const rejectDeviceSignatureInvalid = () => rejectDeviceAuthInvalid("
            "\"device-signature\", \"device signature invalid\");\n"
            f"{T5}if (!verifyDeviceSignature(device.publicKey, payload, device.signature)) {{"
        )

        patched_verify = 0
        for fpath in glob.glob(os.path.join(dist_dir, "gateway-cli-*.js")):
            content = open(fpath).read()
            if old_verify in content:
                content = content.replace(old_verify, new_verify)
                open(fpath, "w").write(content)
                patched_verify += 1
                print(f"  Patched verification in {os.path.basename(fpath)}")

        assert patched_verify > 0, "Verification call site not found in gateway-cli-*.js"
        print(f"  -> Patched verification in {patched_verify} files")
        print("v3 device auth patch complete.")
      '';

      patchedGateway = pkgs.runCommand "${gatewayBase.name}-v3-patched" { } ''
        cp -a ${gatewayBase} $out
        chmod -R u+w $out
        substituteInPlace $out/bin/openclaw \
          --replace-fail "${gatewayBase}" "$out"
        echo "Applying v3 device auth payload patch..."
        ${v3PatchScript} $out/lib/openclaw/dist
      '';
    in
    {
      nixpkgs.overlays = [ inputs.nix-openclaw.overlays.default ];
      imports = [ inputs.nix-openclaw.nixosModules.openclaw-gateway ];

      environment.systemPackages = [
        patchedGateway
        pkgs.lsof
      ];

      services.openclaw-gateway = {
        enable = true;
        package = patchedGateway;
        config.gateway.auth.allowTailscale = true;

        # The upstream module creates /etc/openclaw owned by root:root via tmpfiles.
        # The gateway runs as the `openclaw` user and needs to write temp files there
        # (atomic write pattern). This chown runs as root ('+' prefix) before each start.
        #
        # Must use the module's `execStartPre` option — setting
        # systemd.services.*.serviceConfig.ExecStartPre directly gets overridden by
        # the module's own empty-list default for that key.
        execStartPre = [ "+${pkgs.coreutils}/bin/chown -R openclaw:openclaw /etc/openclaw" ];
      };

      # Harden the gateway system service.
      # Note: MemoryDenyWriteExecute omitted — Go runtime requires W+X memory.
      # ProtectSystem = "strict" makes /etc read-only for the service; ReadWritePaths
      # whitelists /etc/openclaw for the gateway's atomic config writes.
      # tailscale serve: the gateway needs the CLI in PATH and operator
      # permissions on the tailscale daemon socket.
      services.tailscale.extraSetFlags = [ "--operator=openclaw" ];
      systemd.services.openclaw-gateway.path = [ pkgs.tailscale ];

      systemd.services.openclaw-gateway.serviceConfig = {
        ProtectSystem = "strict";
        ReadWritePaths = [ "/etc/openclaw" "/var/lib/openclaw" ];
        ProtectHome = "read-only";
        PrivateTmp = true;
        NoNewPrivileges = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        ProtectClock = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        SystemCallArchitectures = "native";
      };
    };
}
