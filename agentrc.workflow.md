I'll help you understand the workflow for running through all the commands in this AgentRC project. Let me first load the repository structure and command reference to give you a comprehensive guide.Let me try a different approach to find the commands:Based on the semantic and lexical search results, here's a comprehensive workflow for running through all the commands in the **AgentRC** project:

## Complete AgentRC Command Workflow

The project has **9 main commands**. Here's the recommended execution order for a complete walkthrough:

### 1. **`agentrc init`** — Interactive Setup
```bash
npx agentrc init [path]
```
**Purpose:** Guided interactive setup for a repository
- Analyzes the repo
- Generates instructions and configs
- Optionally clones from GitHub or Azure DevOps
- Use `--yes` to skip prompts, `--github` or `--provider azure` to specify source
- Creates `.agentrc-cache` for remote repos

---

### 2. **`agentrc analyze`** — Inspect Repository
```bash
npx agentrc analyze [path]
npx agentrc analyze --output report.json    # Save report
npx agentrc analyze --output report.md      # Markdown format
```
**Purpose:** Detect languages, frameworks, monorepo structure, areas
- Scans for: languages, package manager, build system, test setup
- Detects monorepo workspaces
- Output: JSON or Markdown

---

### 3. **`agentrc readiness`** — AI Readiness Assessment
```bash
npx agentrc readiness [path]
npx agentrc readiness --visual              # HTML report
npx agentrc readiness --output report.html
npx agentrc readiness --per-area            # Per-area breakdown
npx agentrc readiness --fail-level 3        # CI gate (fail if < level 3)
```
**Purpose:** Score repo across **9 maturity pillars**:
- **Repo Health:** Style, Build, Testing, Docs, Dev Environment, Code Quality, Observability, Security
- **AI Setup:** AI Tooling setup

Maturity levels: 1 (Functional) → 5 (Autonomous)

---

### 4. **`agentrc instructions`** — Generate Copilot Instructions
```bash
npx agentrc instructions                    # Default: .github/copilot-instructions.md
npx agentrc instructions --areas            # Root + all detected areas
npx agentrc instructions --areas-only       # File-based area instructions only
npx agentrc instructions --area frontend    # Single area
npx agentrc instructions --strategy nested  # AGENTS.md + detail files
npx agentrc instructions --claude-md        # Generate CLAUDE.md (nested)
```
**Purpose:** Generate AI instructions for Copilot SDK
- Strategies: `flat` (single file) or `nested` (hub + area details)
- Integrates with Copilot CLI for model selection

---

### 5. **`agentrc eval`** — Evaluate Instructions
```bash
npx agentrc eval --init                     # Scaffold eval config (agentrc.eval.json)
npx agentrc eval --init --count 10          # Generate 10 test cases
npx agentrc eval agentrc.eval.json          # Run evaluation
npx agentrc eval --model gpt-4 --judge-model claude-sonnet-4.5
npx agentrc eval --fail-level 80            # CI gate: fail if pass rate < 80%
npx agentrc eval --output results.json      # Save results
```
**Purpose:** Measure instruction quality by comparing with/without instructions
- Judge model rates responses
- Generates trajectory viewer

---

### 6. **`agentrc generate`** — Generate Configs
```bash
npx agentrc generate instructions [path]    # Same as `agentrc instructions`
npx agentrc generate agents [path]          # Generate AGENTS.md
npx agentrc generate mcp [path]             # MCP server config
npx agentrc generate vscode [path]          # VS Code settings
```
**Purpose:** Generate ecosystem configs
- Supports monorepos with `--per-app`

---

### 7. **`agentrc pr`** — Create PR with Configs
```bash
npx agentrc pr owner/repo                   # GitHub
npx agentrc pr org/project/repo --provider azure
npx agentrc pr owner/repo --branch custom-branch
```
**Requires:**
- `GITHUB_TOKEN` / `GH_TOKEN` for GitHub
- `AZURE_DEVOPS_PAT` for Azure DevOps

**Purpose:** Clone repo, generate instructions + configs, create PR

---

### 8. **`agentrc batch`** — Batch Process Multiple Repos
```bash
npx agentrc batch owner/repo1 owner/repo2 owner/repo3
npx agentrc batch --provider azure org/project/repo1 org/project/repo2
npx agentrc batch --output results.json
```
**Purpose:** Run instructions generation across multiple repos in parallel

---

### 9. **`agentrc batch-readiness`** — Batch Readiness Report
```bash
npx agentrc batch-readiness
npx agentrc batch-readiness --output report.html
npx agentrc batch-readiness --policy ./policies.json
```
**Purpose:** Generate HTML report comparing readiness across multiple repos

---

### 10. **`agentrc tui`** — Interactive Terminal UI
```bash
npx agentrc tui                             # Full interactive mode
npx agentrc tui --repo /path/to/repo
npx agentrc tui --no-animation              # Skip banner
```
**Purpose:** Interactive menu for generation, evaluation, batch workflows
- Default when run with no args

---

## Recommended Full Workflow

```bash
# 1. Set up repo
npx agentrc init /path/to/repo

# 2. Analyze structure
npx agentrc analyze /path/to/repo --output analysis.json

# 3. Assess readiness
npx agentrc readiness /path/to/repo --visual --output readiness.html

# 4. Generate instructions
npx agentrc instructions --repo /path/to/repo --areas

# 5. Create eval scaffold
npx agentrc eval --init --repo /path/to/repo

# 6. Run evaluation (after editing agentrc.eval.json)
npx agentrc eval agentrc.eval.json --repo /path/to/repo

# 7. Create PR with all configs
npx agentrc pr owner/repo

# 8. For multiple repos
npx agentrc batch owner/repo1 owner/repo2 --output batch-results.json
```

---

## Build & Test Commands
```bash
npm run build          # Compile TypeScript → dist/
npm run typecheck      # Type check
npm run lint           # ESLint
npm run test           # Single run
npm run test:watch     # Watch mode
```

**Run without building:**
```bash
npx tsx src/index.ts <command> [options]
```

---

## Global Flags (All Commands)
- `--json` — Machine-readable JSON to stdout
- `--quiet` — Suppress progress output  
- `--accessible` — Screen reader friendly
