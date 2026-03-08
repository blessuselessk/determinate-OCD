# PROSE Framework - Primitive Composability Schema

let ProjectSchema = { 
  metadata = {
    name = "PROSE Primitive Composability Schema",
    description = "Schema for defining the architectural constraints and types for AI-Native Development based on the PROSE framework (Progressive Disclosure, Reduced Scope, Orchestrated Composition, Safety Boundaries, Explicit Hierarchy).",
    version = "0.1.0",
    author = "Ashley Barr",
    date = "2026-03-07",
    keywords = ["prose", "ai-native", "schema", "composition", "agentic"],
  },
} in


# A SemVer contract enforces semantic versioning (Major.Minor.Patch).
# This acts as a runtime type-checker. If an agent, author, or the APM compiler
# ever tries to provide a schema version like "v1" or "latest", 
# the Nickel interpreter will actively throw a contract violation error 
# because it doesn't match the "x.y.z" regular expression.
let SemVer = std.contract.from_predicate (fun s => 
  std.is_string s && std.string.is_match "^[0-9]+\\.[0-9]+\\.[0-9]+$" s
) in

# -- File Hierarchy Schema --
# A generic recursive Tree node representing the boundless filesystem.
# Can be either a File (with text/binary content) or a Directory mapping names to more TreeNodes.
let rec TreeNode_contract = {
  metadata
    | doc "System or application-specific metadata for the node."
    | default = {}
    | {
        permissions | optional | String,
        last_modified | optional | String,
        digest | optional | String | doc "Content-addressable hash (e.g. SHA-256) of the node.",
      } 
      & (if type == 'File then {
          size_bytes | optional | Number,
          mime_type | optional | String,
          extension | optional | String,
          encoding | default = "utf-8" | String,
        } else {}),

  type 
    | doc "The kind of node in the filesystem."
    | [| 'File, 'Directory |],
    
  content 
    | doc "The textual content of the node if it is a File."
    | optional | String,
    
  children 
    | doc "Bounded or unbounded child nodes if this is a Directory."
    | optional | { _ : TreeNode_contract },
} in

# -- Semantic Versioning Helpers --
# The following helpers allow the schema to dynamically compute parent versions
# by looking at an array of parsed "x.y.z" strings and bubbling up the maximum.

# Parses a "Major.Minor.Patch" string into a Nickel record with numeric fields.
# Example: "1.2.14" -> { major = 1, minor = 2, patch = 14 }
let parse_semver = fun s =>
  let parts = std.string.split "." s in
  {
    major = std.string.to_number (std.array.at 0 parts),
    minor = std.string.to_number (std.array.at 1 parts),
    patch = std.string.to_number (std.array.at 2 parts)
  }
in

# Standard comparator for two SemVer strings `a` and `b`.
# Returns 1 if `a > b`, -1 if `a < b`, and 0 if they are exactly equal.
# It checks Major, then Minor, then Patch sequentially.
let compare_semver = fun a b =>
  let pa = parse_semver a in
  let pb = parse_semver b in
  if pa.major > pb.major then 1
  else if pa.major < pb.major then -1
  else if pa.minor > pb.minor then 1
  else if pa.minor < pb.minor then -1
  else if pa.patch > pb.patch then 1
  else if pa.patch < pb.patch then -1
  else 0
in

# Given an array of SemVer strings, iterates through to find the absolute maximum version.
# Uses std.array.fold_left to maintain the highest seen version (initialized at "0.0.0").
let max_semver = fun arr =>
  std.array.fold_left (fun acc v => 
    if compare_semver v acc == 1 then v else acc
  ) "0.0.0" arr
in

# An Assertion is a testable rule governing the interactions of primitives.
let Assertion = {
  id | String,
  version | SemVer | default = "1.0.0",
  description | String,
  severity | [| 'Error, 'Warning, 'Info |] | default = 'Error,
} in

# Let's decompose the core constraints into rich records of assertions
let ProseConstraint = {
  id | String,
  principle | String,
  inducedProperty | String,
  assertions | Array Assertion,
  # Dynamically computed version that "bubbles up" the max version of any child assertion
  version | SemVer | force = max_semver (std.array.map (fun a => a.version) assertions),
} in


let ProseConstraints = {
  ProgressiveDisclosure
    | ProseConstraint
    | default
    = {
        id = "P",
        principle = "Context arrives just-in-time, not just-in-case",
        inducedProperty = "Efficient context utilization",
        assertions = [
          {
            id = "PD-01",
            description = "Context primitives (.context.md) cannot invoke active or passive primitives.",
            severity = 'Error,
          },
          {
            id = "PD-02",
            description = "Agents load context strictly via explicit markdown references.",
            severity = 'Error,
          }
        ]
      },
      
  ReducedScope
    | ProseConstraint
    | default
    = {
        id = "R",
        principle = "Match task size to context capacity",
        inducedProperty = "Manageable complexity",
        assertions = [
          {
            id = "RS-01",
            description = "Subagent spawning must provide explicit or default runTimeoutSeconds bounds.",
            severity = 'Error,
          },
          {
            id = "RS-02",
            description = "Prompts and Agents cannot directly invoke Specs.",
            severity = 'Warning,
          }
        ]
      },
      
  OrchestratedComposition
    | ProseConstraint
    | default
    = {
        id = "O",
        principle = "Simple things compose; complex things collapse",
        inducedProperty = "Flexibility, reusability",
        assertions = [
          {
            id = "OC-01",
            description = "Agents delegate context via handoffs frontmatter.",
            severity = 'Error,
          },
          {
            id = "OC-02",
            description = "Agents spawn concurrent execution via the agent/runSubagent tool.",
            severity = 'Error,
          }
        ]
      },
      
  SafetyBoundaries
    | ProseConstraint
    | default
    = {
        id = "S",
        principle = "Autonomy within guardrails",
        inducedProperty = "Reliability, security",
        assertions = [
          {
            id = "SB-01",
            description = "Agents must explicitly declare allowed tools.",
            severity = 'Error,
          },
          {
            id = "SB-02",
            description = "Instructions are strictly passive and never invoke execution.",
            severity = 'Error,
          }
        ]
      },
      
  ExplicitHierarchy
    | ProseConstraint
    | default
    = {
        id = "E",
        principle = "Specificity increases as scope narrows",
        inducedProperty = "Modularity, inheritance",
        assertions = [
          {
            id = "EH-01",
            description = "Instructions are injected geographically via applyTo globs.",
            severity = 'Error,
          },
          {
            id = "EH-02",
            description = "Agents inherit compiled AGENTS.md context via directory tree walk.",
            severity = 'Error,
          }
        ]
      },
} in


let Tier = [| 'active, 'passive, 'meta |] in

# A generic wrapper for any file that has YAML frontmatter and a markdown body
let MarkdownDocument = fun FrontmatterType => {
  frontmatter | FrontmatterType | doc "The YAML frontmatter extracted from the top of the file.",
  body | String | doc "The markdown content following the frontmatter (the 'body' of the document).",
} in

# -- Core Primitive Contracts --

let AgentFrontmatter = {
  description | String | doc "Role-based persona with bounded tool access and optional handoffs.",
  tools | Array String | optional,
  handoffs | Array String | optional,
  model | String | optional,
} in

let InstructionFrontmatter = {
  applyTo | String | doc "Persistent rules scoped by file glob. Automatically injected into agents.",
  description | String | optional,
} in

let PromptFrontmatter = {
  name | String | doc "Human readable title of the prompt" | optional,
  description | String | doc "Reusable phased workflow invoked on demand.",
  mode | String | optional,
  agent | String | optional,
  model | String | optional,
  tools | Array String | optional,
  mcp | Array String | optional,
  
  # Structured properties
  input | { _ : Dyn } | optional | doc "Structured input variables expected by the prompt",
  properties | Array { name | String, description | String | optional, type | String | optional } | optional | doc "List of properties or parameters",
  metadata | { _ : Dyn } | optional | doc "Arbitrary structured metadata",
} in

let ContextFrontmatter = {
  description | String | optional | doc "Reference knowledge loaded on demand via markdown links.",
} in

let MemoryFrontmatter = {
  # Decision log persisting across sessions.
} in

let SpecFrontmatter = {
  description | String | optional | doc "Implementation-ready blueprint.",
} in

let SkillFrontmatter = {
  name | String,
  description | String | doc "Packaged capability for distribution and auto-discovery.",
  license | String | optional,
  "allowed-tools" | Array String | optional,
  metadata | { _ : String } | optional,
} in

# -- Runtime Configuration Options --

let SubagentDefaults = {
  runTimeoutSeconds | Number | optional | doc "Default timeout applied to subagents explicitly or implicitly via config.",
} in

let SessionsSpawnConfig = {
  session | {
    mainKey | String | default = "main",
    scope | String | default = "per-sender",
  } | optional,
  
  agents | {
    defaults | {
      subagents | SubagentDefaults | optional
    } | optional
  } | optional
} in

# -- The Project Definition --

let Project = {
  name
    | String
    | doc "Name of the repository or system",

  version
    | SemVer
    | doc "Semantic version of the underlying PROSE configuration"
    | default
    = "1.0.0",

  contracts = {
    TreeNode = TreeNode_contract,
  },

  proseConstraints
    | ProseConstraints
    | doc "The guiding principles of AI-Native development enforced in this project, extracted from PROSE specification."
    | default
    = ProseConstraints,

  proseRoots
    | Array String
    | doc "Directories that may contain PROSE descriptions"
    | default
    = [ "docs", "specs", "architecture", "systems", "domains" ],

  agentRoot
    | String
    | doc "Root directory containing agent primitives"
    | default
    = ".github",

  agentPrimitives
    | {
        agents | String | doc "Agent behavior definitions (Active)" | default = "agent",
        prompts | String | doc "Prompt templates used by agents (Active)" | default = "prompt",
        instructions | String | doc "Operational instructions for agents (Passive)" | default = "instructions",
        contexts | String | doc "Reference knowledge loaded on demand (Passive)" | default = "context",
        memories | String | doc "Decision logs persisting across sessions (Passive)" | default = "memory",
        specs | String | doc "Implementation-ready blueprints (Passive)" | default = "spec",
        skills | String | doc "Packaged capabilities (Meta)" | default = "skills",
      }
    | default
    = {},

  # -- File Hierarchy Instantiation --
  
  # The system allows unbound directory creation via a TreeNode filesystem representation,
  # but enforces the presence of a Git platform directory and its specific structured primitives.
  filesystem
    | TreeNode_contract
    | (
        let HasGitPlatform = std.contract.from_predicate (fun fs =>
          let platforms = [".github", ".gitlab", ".gitea", ".bitbucket", ".forgejo"] in
          let fields = std.record.fields fs.children in
          std.array.any (fun p => std.array.elem p fields) platforms
        ) in
        HasGitPlatform
      )
    | doc "Root of the project file system. Fully unbounded except for specific structure locks."
    | default = (
        let GitPlatformDir = {
          type = 'Directory,
          children | {
            agents | TreeNode_contract | optional,
            prompts | TreeNode_contract | optional,
            instructions | TreeNode_contract | optional,
            contexts | TreeNode_contract | optional,
            memories | TreeNode_contract | optional,
            specs | TreeNode_contract | optional,
            skills | TreeNode_contract | optional,
            ..
          }
        } in
        {
          type = 'Directory,
          children = {
            # Defaults to `.github` for scaffolding, but users can rename it to `.gitlab` 
            # and it will still pass the HasGitPlatform contract check!
            ".github" | GitPlatformDir = {
              type = 'Directory,
              children = {
                agents = { type = 'Directory, children = {} },
                prompts = { type = 'Directory, children = {} },
                instructions = { type = 'Directory, children = {} },
                contexts = { type = 'Directory, children = {} },
                memories = { type = 'Directory, children = {} },
                specs = { type = 'Directory, children = {} },
                skills = { type = 'Directory, children = {} },
              }
            }
          }
        }
      ),

  proseFilenameConvention
    | String
    | doc "Filename pattern for PROSE documents"
    | default
    = "<aspect>.<primitive>.md",

  sessionsSpawnConfig
    | SessionsSpawnConfig
    | doc "Configuration overrides for the OpenClaw subagent spawner"
    | default
    = {},
}

in Project
