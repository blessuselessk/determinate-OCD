# nixpkgs-review

> Tool for reviewing nixpkgs pull requests by automatically building affected packages, providing test environments, and integrating with GitHub for result reporting.

Source: `github:Mic92/nixpkgs-review`

## Purpose

nixpkgs-review automates the process of testing changes in NixOS/nixpkgs pull requests. It evaluates which packages are affected, builds them, drops you into a shell with the results, and can post build reports as PR comments. Supports ofborg evaluation reuse, multi-architecture builds, and NixOS test execution.

______________________________________________________________________

### Setup

Source: https://github.com/Mic92/nixpkgs-review

**Run directly from nixpkgs:**

```bash
nix run 'nixpkgs#nixpkgs-review'
```

**Build from source:**

```bash
nix-build
./result/bin/nixpkgs-review
```

**Prerequisites:**
- Local nixpkgs repository (non-shallow clone recommended)
- GitHub token for API access (optional but recommended): set `GITHUB_TOKEN` env var or use `--token`
- Optional tools: `nix-output-monitor` (nom), `glow`, `delta`

______________________________________________________________________

### Core Commands

Source: https://github.com/Mic92/nixpkgs-review

| Command | Description |
|---------|-------------|
| `pr [NUMBER\|URL]` | Review a specific pull request |
| `rev [COMMIT]` | Review a local commit (defaults to HEAD) |
| `wip` | Review uncommitted changes (`--staged` for staged only) |

**Post-review actions** (available inside the nix-shell after build):

| Action | Description |
|--------|-------------|
| `approve` | Approve the PR on GitHub |
| `merge` | Merge the PR (requires maintainer access) |
| `post-result` | Upload build results as a PR comment |
| `comments` | Display PR review comments |

______________________________________________________________________

### Common Usage Examples

Source: https://github.com/Mic92/nixpkgs-review

**Simple PR review:**

```bash
nixpkgs-review pr 37242
```

**Build specific packages and post results:**

```bash
nixpkgs-review pr -p redis -p openjpeg --post-result 49262
```

**Run a custom command instead of interactive shell:**

```bash
nixpkgs-review pr --run 'jq < report.json' --systems all 340297
```

**Test NixOS integration tests:**

```bash
nixpkgs-review pr -p nixosTests.ferm 47077
```

**Review uncommitted changes in sandbox:**

```bash
nixpkgs-review wip --sandbox
```

**Use specific checkout strategy:**

```bash
nixpkgs-review pr --checkout commit 44534
```

______________________________________________________________________

### Key Flags

Source: https://github.com/Mic92/nixpkgs-review

**Building and testing:**

| Flag | Description |
|------|-------------|
| `-p, --package` | Build specific packages |
| `-P, --skip-package` | Exclude packages from build |
| `--package-regex` | Match packages by regex |
| `--skip-package-regex` | Exclude by regex |
| `--build-args` | Pass arguments to nix-build |
| `--checkout [merge\|commit]` | Control checkout strategy |
| `--no-shell` | Skip interactive shell (for scripting) |

**Reporting:**

| Flag | Description |
|------|-------------|
| `--post-result` | Post results as GitHub PR comment |
| `--print-result` | Print results to terminal |
| `--no-logs` | Exclude failed build logs from reports |
| `--run 'COMMAND'` | Execute command in nix-shell instead of interactive session |

**System and architecture:**

| Flag | Description |
|------|-------------|
| `--systems [all\|linux\|darwin\|current\|x86_64\|aarch64]` | Target architectures |
| `--eval [local\|ofborg]` | Evaluation source (ofborg reuses CI results) |

**Advanced:**

| Flag | Description |
|------|-------------|
| `--remote URL` | Override upstream repo (for forks) |
| `--extra-nixpkgs-config` | Provide nixpkgs configuration |
| `--token` / `GITHUB_TOKEN` | GitHub API authentication |
| `--sandbox` | Run tests in isolated sandbox (experimental) |

______________________________________________________________________

### Features

Source: https://github.com/Mic92/nixpkgs-review

- **ofborg integration**: Reuses CI evaluation results when available, falls back to local evaluation
- **Interactive shell**: Drops into nix-shell with successfully-built packages for manual testing
- **Remote building**: Supports distributed builds across multiple machines
- **GitHub integration**: Posts comments, approves/merges PRs, displays reviews
- **NixOS test support**: Can build and run NixOS integration tests
- **Markdown reports**: Generates formatted build result summaries
- **Package filtering**: Selective building for mass-rebuild scenarios
- **Multi-PR batching**: Review multiple PRs sequentially in a single session

______________________________________________________________________

## Use Cases

- **PR review**: Build and test affected packages before approving nixpkgs PRs
- **CI complement**: Local validation when CI is slow or incomplete
- **Mass rebuilds**: Filter and test specific packages in large-scale changes
- **Staging verification**: Use `wip` to validate local changes before committing
- **Automated reporting**: Script `--no-shell --post-result` for bot-driven review workflows
