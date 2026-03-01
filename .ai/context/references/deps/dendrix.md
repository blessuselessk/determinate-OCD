# dendrix

> Community platform for sharing and discovering dendritic Nix sub-trees. The AUR of Dendritic Nix.

Source: `github:vic/dendrix`

### Recommended Repository Structure (Plain Text)

Source: https://context7.com/vic/dendrix/llms.txt

Illustrates the recommended file organization for a Dendrix repository to promote community sharing. It highlights conventions for community modules, host-specific configurations, user-specific settings, and private directories.

```plaintext
# Recommended repository structure:
./flake.nix                           # Minimal - just imports ./modules
./modules/                            # All flake-parts modules (auto-imported)
./modules/community/                  # Modules shared with Dendrix community
./modules/community/ai.nix            # AI aspect - shared
./modules/community/ssh.nix           # SSH aspect - shared
./modules/community/+vim/             # Vim configs (flagged with +vim)
./modules/community/+vim/lsp.nix      # +vim +lsp flagged
./modules/hosts/                      # Host-specific (not shared)
./modules/hosts/myhost/               # Hardware-specific configs
./modules/users/                      # User-specific (not shared)
./modules/users/vic/                  # Personal credentials/settings
./modules/private/                    # Never shared (private infix)

# Convention highlights:
# - Paths with 'private' infix are never shared to community
# - Paths with '_' prefix are ignored by import-tree
# - Use +flag naming for capability-based filtering
# - modules/community/ is auto-detected for sharing
```

______________________________________________________________________

### Import Dendrix Layers for Pre-configured Functionality in Nix

Source: https://context7.com/vic/dendrix/llms.txt

Shows how to utilize Dendrix Layers, which are pre-configured modules combining aspects from multiple community sources. These layers offer 'batteries-included' functionality for various use cases like VIM editing, AI, or DevOps.

```nix
# modules/layers.nix
{
  imports = [
    # Import the vix layer (see https://github.com/vic/dendrix/tree/main/dev/layers/vix)
    inputs.dendrix.vix

    # Future layers: inputs.dendrix.ai, inputs.dendrix.gaming, etc.
  ];
}

```

### Dendrix import-trees

Source: https://github.com/vic/dendrix/blob/main/dev/book/src/Dendrix-Trees.md

Dendrix discovers what `aspect`s and which Nix configuration `class`es are provided by the dendritic community repository sources. This discovery process is a foundational step towards the project's goal of allowing people to share dendritic configurations and socially enhance their capabilities. The sidebar UI plays a crucial role in this by documenting discovered aspects and classes, showing community naming conventions, and facilitating the reuse of existing aspects via import-trees.

______________________________________________________________________

### Dendrix

Source: https://context7.com/vic/dendrix/llms.txt

Dendrix consists of two main components: **Import Trees** which are references to shared dendritic configurations from community repositories, and **Layers** which are blessed cross-repository flake-parts modules combining multiple community sources. The Dendritic pattern organizes configurations around features/aspects rather than hosts, where each `.nix` file is a flake-parts module that can contribute to multiple configuration classes simultaneously. This enables feature-centric configuration with closures, minimal file imports, and easy sharing of cross-platform setups.

______________________________________________________________________

### dev/community/your-repo.nix - Repository configuration

Source: https://context7.com/vic/dendrix/llms.txt

Dendrix enables a new paradigm for NixOS configuration sharing where community members contribute dendritic modules that others can selectively import and compose. The import-tree mechanism allows fine-grained control over which aspects to include, while layers provide curated combinations of community modules for specific use cases like gaming, AI development, or DevOps workflows.

The project fosters collaboration around aspect naming conventions and best practices, enabling configurations that transcend individual host or user specifics. By following the Dendritic pattern, users benefit from feature closures (all related code in one place), automatic file loading, and the ability to incrementally add or remove capabilities without restructuring their entire configuration. Whether you're a NixOS newcomer seeking batteries-included setups or an experienced user wanting to share your configurations, Dendrix provides the infrastructure for community-driven Nix configuration management.
