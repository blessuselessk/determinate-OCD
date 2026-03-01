# determinate

> Enterprise Nix distribution with validated downstream Nix, FlakeHub integration, and automated system management.

Source: `github:DeterminateSystems/determinate`

### Install Determinate Nix

Source: https://docs.determinate.systems/guides/migrating-from-upstream-nix

This command downloads and executes the Determinate Nix Installer script to install Determinate Nix. It uses curl to fetch the script and pipes it to sh for execution with the '--determinate' flag.

```shell
curl -fsSL https://install.determinate.systems/nix | \
  sh -s -- install --determinate
```

______________________________________________________________________

### Buildkite Pipeline for FlakeHub Cache

Source: https://docs.determinate.systems/guides/buildkite

This Buildkite pipeline configures the environment, installs Determinate Nix, obtains an OIDC token for FlakeHub authentication, sets up Magic Nix Cache, builds packages, and pushes store paths to FlakeHub Cache. It requires specific environment variables to be set.

```yaml
steps:
  - label: Push store paths to FlakeHub Cache
    env:
      DETERMINATE_NIX_INSTALL_URL: https://install.determinate.systems/nix?ci=buildkite
      MAGIC_NIX_CACHE_CLOSURE_URL: https://install.determinate.systems/magic-nix-cache-closure/branch/main/X64-Linux?ci=buildkite
      MAGIC_NIX_CACHE_LISTEN: 127.0.0.1:37515
    command: |
      echo "Installing Determinate Nix"

      curl --proto '=https' --tlsv1.2 -sSf -L "${DETERMINATE_NIX_INSTALL_URL}" | \
        sh -s -- install linux \
          --determinate \
          --no-confirm \
          --init none

      nohup /usr/local/bin/determinate-nixd daemon &
      export NIX_REMOTE="daemon"

      echo "Waiting for Determinate Nixd status"

      while ! determinate-nixd status &>/dev/null; do
        sleep 0.1;
      done

      echo "Determinate Nix installed"

      # Set PATH to include Nix-created directories and persist that environment variable in a file
      PATH="${PATH}:/root/.nix-profile/bin/"

      echo "Fetching OIDC token for Buildkite"

      buildkite_oidc_token="$(
        buildkite-agent oidc request-token \
        --claim 'organization_id' \
        --claim 'pipeline_id' \
        --audience "api.flakehub.com"
      )"

      echo "Logging in to FlakeHub using OIDC token"

      echo "${buildkite_oidc_token}" | determinate-nixd login token --token-file /dev/stdin

      echo "Installing Magic Nix Cache"

      magic_nix_cache_closure="$(curl -L "${MAGIC_NIX_CACHE_CLOSURE_URL}" | xz -d | sudo "$(which nix-store)" --import | tail -n1 | head -n1)"
      sudo ln -sf "${magic_nix_cache_closure}/bin/magic-nix-cache" /usr/bin/magic-nix-cache

      magic_nix_cache_startup_file="/tmp/mnc-startup"

      echo "Waiting for Magic Nix Cache to start up"

      nohup magic-nix-cache --listen "${MAGIC_NIX_CACHE_LISTEN}" --startup-notification-file "${magic_nix_cache_startup_file}" &>/tmp/mnc.log &
      (
        started=0
        for n in {1..6}; do
          if [ -e "${magic_nix_cache_startup_file}" ]; then
            echo "Magic Nix Cache daemon has successfully started up after ${n} attempt(s)"
            started=1
            break
          else
            echo "Waiting on Magic Nix Cache daemon; on attempt ${n}"
            sleep 2
          fi
        done

        if [[ "${started}" != "1" ]]; then
          echo "The Magic Nix Cache daemon did not start up within 60 seconds; exiting"
          exit 1
        fi
      ) || true

      # Build whatever you'd like with Nix
      nix build .#my-package-1
      nix build .#my-package-2

      # Drain Magic Nix Cache
      curl -XPOST "http://${MAGIC_NIX_CACHE_LISTEN}/api/workflow-finish"

      echo "Store paths successfully pushed to FlakeHub Cache!"
```

______________________________________________________________________

### Publish Nix Flake to FlakeHub (Buildkite Pipeline)

Source: https://docs.determinate.systems/guides/buildkite

This YAML configuration defines a Buildkite pipeline step for publishing a Nix flake to FlakeHub. It sets up environment variables for Determinate Nix and FlakeHub, installs the necessary tools, retrieves an OIDC token via Buildkite, and conditionally publishes the flake using `flakehub-push` if a Git tag is present.

```yaml
steps:
  - label: Published tagged release to FlakeHub
    env:
      DETERMINATE_NIX_INSTALL_URL: https://install.determinate.systems/nix?ci=buildkite
      FLAKEHUB_PUSH_BINARY_URL: https://install.determinate.systems/flakehub-push/branch/main/X64-Linux?ci=buildkite
      # Set these to match your own flake
      FLAKE_ORG: my-org
      FLAKE_NAME: my-flake
      FLAKE_VISIBILITY: unlisted # could also be public or private
    command: |
      echo "Installing Determinate Nix"

      curl --proto '=https' --tlsv1.2 -sSf -L "${DETERMINATE_NIX_INSTALL_URL}" | \
        sh -s -- install linux \
          --determinate \
          --no-confirm \
          --init none

      echo "Installing flakehub-push"

      curl -L "${FLAKEHUB_PUSH_BINARY_URL}" | sudo tee /usr/bin/flakehub-push &>/dev/null
      sudo chmod +x /usr/bin/flakehub-push

      echo "Fetching OIDC token for Buildkite"

      buildkite_oidc_token="$(
        buildkite-agent oidc request-token \
        --claim 'organization_id' \
        --claim 'pipeline_id' \
        --audience "api.flakehub.com"
      )"

      # Required environment variables for flakehub-push
      FLAKEHUB_PUSH_OIDC_TOKEN="${buildkite_oidc_token}"
      FLAKEHUB_PUSH_REPOSITORY="${FLAKE_ORG}/${FLAKE_NAME}"

      # Publish the flake if and only if it's a tag reference
      if [[ ! -z "${BUILDKITE_TAG:-}" ]]; then
        flakehub-push \
          --tag "${BUILDKITE_TAG}" \
          --visibility "${FLAKE_VISIBILITY}" \
          --include-output-paths

        echo "The flake ${FLAKEHUB_PUSH_REPOSITORY} has been published to FlakeHub with version ${BUILDKITE_TAG}"
      fi
```

______________________________________________________________________

### NixOS flake configuration for Determinate

Source: https://docs.determinate.systems/guides/advanced-installation

This snippet shows how to configure a NixOS system to use the Determinate flake, including adding the default Determinate NixOS module.

```nix
{
  inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
 
  outputs = { determinate, nixpkgs, ... }:
    {
      nixosConfigurations.my-workstation = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Load the Determinate module
          determinate.nixosModules.default
        ];
      };
    };
}
```

______________________________________________________________________

### Verify Nix and Determinate Nix Daemon Status

Source: https://docs.determinate.systems/guides/deploy-nix-macos-ec2

Commands to verify the successful installation and configuration of Nix and the Determinate Nix daemon (`determinate-nixd`). The first command checks the installed Nix version, confirming Nix itself is operational. The second command queries the status of the `determinate-nixd` service, which is crucial for FlakeHub integration and authentication, ensuring it's running and configured correctly.

```bash
# Check Nix works
nix --version

# Verify FlakeHub authentication
determinate-nixd status
```
