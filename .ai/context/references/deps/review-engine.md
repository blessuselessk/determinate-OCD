# review-engine

> Content-addressed AI review system for git-based projects. Platform-agnostic, LLM-pluggable, with mandatory human sign-off.

Status: **Design spec** — not yet implemented.

## Problem

Infrastructure-as-code repos (like this one) auto-deploy from `main`. A broken commit on main means a broken deployment. GitHub rulesets can enforce CI checks and require PRs, but they can't enforce:

- Nix/dendritic conventions (aspect structure, namespace rules)
- Deploy safety (will this break a running service?)
- Security patterns (secrets handling, hardening)
- That a human actually reviewed specific concerns, not just clicked "approve"

And all of the above should work regardless of which forge hosts the repo.

## Design principles

1. **Content-addressed findings** — finding IDs are hashes of (criterion + file + diff hunk). If code changes, the hash changes, old sign-offs expire automatically.
2. **Platform-agnostic core** — the review engine is a CLI: diff in, findings out. Forge-specific adapters are thin and swappable.
3. **LLM-pluggable** — review criteria are natural language. The engine delegates evaluation to a configurable LLM backend.
4. **Mandatory item-level sign-off** — the human must respond to each finding by its hash. No blanket approvals.

## Architecture

```
┌─────────────────────────────────────┐
│        Review Criteria              │
│  One file per reviewer.             │
│  Natural language checklists.       │
│  Checked into repo.                 │
│                                     │
│  review/criteria/dendritic.md       │
│  review/criteria/deploy-safety.md   │
│  review/criteria/security.md        │
└───────────────┬─────────────────────┘
                │
┌───────────────▼─────────────────────┐
│        Review Engine (CLI)          │
│                                     │
│  For each criterion file:           │
│    1. Read criterion checklist      │
│    2. Read git diff (stdin or ref)  │
│    3. Read relevant context files   │
│    4. Send to LLM backend           │
│    5. Parse structured findings     │
│    6. Hash each finding             │
│    7. Output JSON                   │
│                                     │
│  nix run .#review -- --ref HEAD~1   │
│  nix run .#review -- --diff <file>  │
│  nix run .#review -- --reviewer     │
│      dendritic                      │
└───────────────┬─────────────────────┘
                │
                │  JSON findings
                │
        ┌───────┴───────┐
        ▼               ▼
┌──────────────┐ ┌──────────────┐
│   Adapter:   │ │   Adapter:   │
│   github     │ │   terminal   │
│              │ │              │
│ Posts as PR  │ │ Prints to    │
│ review with  │ │ stdout with  │
│ per-finding  │ │ color/format │
│ comments     │ │              │
├──────────────┤ ├──────────────┤
│   gitlab     │ │   git-notes  │
│   gitea      │ │   tangled    │
│   bitbucket  │ │   (future)   │
└──────┬───────┘ └──────────────┘
       │
┌──────▼───────────────────────────────┐
│       Sign-off Verifier              │
│                                      │
│  Collects:                           │
│    - All finding hashes from review  │
│    - All ack'd hashes from human     │
│  Checks:                             │
│    - Every finding hash has an ack   │
│  Runs as:                            │
│    - CI status check                 │
│    - Pre-merge hook                  │
│    - Local CLI                       │
│                                      │
│  nix run .#verify-signoff -- --pr 1  │
│  nix run .#verify-signoff -- --local │
└──────────────────────────────────────┘
```

## Content-addressed finding IDs

Each finding is identified by a truncated hash:

```
finding_id = sha256(
    criterion_id       # e.g. "dendritic:aspect-one-file"
  + file_path          # e.g. "modules/community/ocd/openclaw-gateway.nix"
  + normalized_hunk    # the diff hunk, whitespace-normalized
)[:8]
```

A finding rendered for humans:

```
[deploy:a3f8c2e1] gateway.bind changed to "tailnet" — verify
fogell's Tailscale is active and firewall trusts tailscale0
```

A human sign-off referencing it:

```
Ack deploy:a3f8c2e1 — fogell includes ocd.networking which trusts tailscale0
```

Properties:
- **Deterministic**: same code + same criterion = same hash, always.
- **Self-invalidating**: amend the PR → hunk changes → hash changes → old ack invalid → must re-review.
- **Tamper-evident**: you can't ack a hash without seeing the specific code it refers to.
- **No coordination**: no central counter, no database, works offline.

## Review criteria format

Each criterion file is a markdown checklist in `review/criteria/`. The engine passes it to the LLM along with the diff. Example:

```markdown
# deploy-safety

Context: This repository auto-deploys to NixOS hosts from `main` via
`system.autoUpgrade`. Changes that break evaluation or service startup
will be deployed automatically within 15 minutes.

## Checklist

- [ ] If host configs changed, do all referenced aspects exist?
- [ ] If secrets paths changed, are the corresponding .age files present?
- [ ] If a systemd service was modified, will it start successfully?
      (Check: ExecStart binary exists, User/Group exist, paths are valid)
- [ ] If networking config changed, will the host remain SSH-reachable?
- [ ] If the flake input was updated, does `nix flake check` still pass?
```

The engine asks the LLM to evaluate each item against the diff and produce a structured finding per item, or mark it as not applicable.

## LLM backend configuration

```json
{
  "review": {
    "backend": "anthropic",
    "model": "claude-sonnet-4-6",
    "backends": {
      "anthropic": { "apiKeyEnv": "ANTHROPIC_API_KEY" },
      "openai": { "apiKeyEnv": "OPENAI_API_KEY" },
      "ollama": { "baseUrl": "http://localhost:11434" }
    }
  }
}
```

The engine constructs a prompt from the criterion file + diff + context files and sends it to whichever backend is configured. The LLM response is parsed into structured findings.

For cost control: review only runs on PR diffs (not full repo), and each reviewer only sees its own criterion + the diff + explicitly listed context files.

## CLI interface

```bash
# Run all reviewers against HEAD vs main
review --ref main..HEAD

# Run a specific reviewer
review --reviewer deploy-safety --ref main..HEAD

# Output formats
review --ref main..HEAD --format json     # machine-readable
review --ref main..HEAD --format terminal # human-readable
review --ref main..HEAD --format github   # post to PR

# Verify sign-off
verify-signoff --findings findings.json --acks acks.json
verify-signoff --pr 1 --adapter github    # reads from PR comments

# Pipe-friendly
git diff main..HEAD | review --stdin --reviewer security
```

## Sign-off flow

### On GitHub (via adapter)

1. PR opened → CI runs `review --format github --ref main..HEAD`
2. Bot posts a review with per-finding comments, each tagged with its hash
3. Human replies to each finding comment with `Ack <hash> — <reason>`
4. CI runs `verify-signoff --pr $PR --adapter github`
5. If all findings ack'd → status check passes → merge unlocked
6. If PR amended → review re-runs → new hashes → unack'd findings → status check fails

### On any forge (via git trailers)

1. Developer runs `review --ref main..HEAD --format terminal` locally
2. Reads findings, adds trailers to merge commit:
   ```
   Ack: deploy:a3f8c2e1 fogell networking trusts tailscale0
   Ack: security:b2c4d6e8 path ref only, no secret content
   ```
3. Pre-merge hook runs `verify-signoff --local` against the commit message
4. If all findings ack'd → merge proceeds

### Sign-off rules

- Each finding hash must have exactly one ack from a human (not a bot).
- An ack must include a non-empty reason (not just the hash).
- Acks are scoped to a specific review run — they don't carry across PRs.
- The verifier is strict: missing ack = fail. No "ack all" shortcut.

## Reviewers for determinate-OCD

| Reviewer | Criterion file | Checks |
|----------|---------------|--------|
| `dendritic` | `review/criteria/dendritic.md` | Aspect conventions, namespace rules, one-file-one-feature, no `specialArgs`, no `default.nix` under modules |
| `deploy-safety` | `review/criteria/deploy-safety.md` | Will `autobots-rebuild` succeed? Secrets wired? Services startable? Host reachable after change? |
| `security` | `review/criteria/security.md` | No plaintext secrets, agenix paths valid, hardening intact, no new attack surface |
| `commit-hygiene` | `review/criteria/commit-hygiene.md` | Conventional commit format, scope reasonable, description present |

## Future considerations

- **Review memory**: store past findings + acks in a git ref (`refs/review/*`) for audit trail.
- **Reviewer composition**: a meta-reviewer that reads other reviewers' findings and flags contradictions.
- **Cost tracking**: log token usage per review run for budget visibility.
- **Caching**: skip re-review for unchanged files across PR updates (hash the inputs).
- **Review policies**: per-branch or per-path rules (e.g. security reviewer only for `modules/*/secrets/`).
