# rime

> REST API middleware that pins Nix flake inputs to latest upstream releases instead of unstable HEAD.

Source: `github:cafkafk/rime`

### Purpose

When you `nix flake update`, inputs typically resolve to HEAD (unstable). RIME redirects to the latest tagged release via a REST API, supporting GitHub, GitLab, Codeberg, Forgejo, Gitea, Sourcehut, and FlakeHub.

### Syntax

```bash
# Latest release
nix run http://rime.cx/v1/github/cafkafk/fortune-kind.tar.gz

# Specific version
nix run http://rime.cx/v1/codeberg.org/cafkafk/hello/version/v0.0.1.tar.gz

# Specific tag
nix run http://rime.cx/v1/codeberg.org/cafkafk/hello/tag/v0.0.1.tar.gz

# Specific branch
nix run http://rime.cx/v1/codeberg.org/cafkafk/hello/branch/main.tar.gz
```

### Supported Forges

GitHub, GitLab (+ self-hosted), Codeberg, Forgejo (+ self-hosted), Gitea (+ self-hosted), Sourcehut (+ self-hosted), FlakeHub

### Use Cases

- **Release tracking**: pin flake inputs to stable releases, not HEAD
- **Multi-forge support**: consistent versioning across different Git hosts
- **Reproducibility**: ensure builds use released versions
