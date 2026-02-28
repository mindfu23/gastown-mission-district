# PR: Multi-Model Agent Router for Gas Town

## Summary

This PR adds a **multi-model agent router** that automatically routes Gas Town roles and tasks to the most appropriate AI model backend. Instead of using a single model for all work, the router optimizes for cost and capability by matching task types to specialized models.

## Motivation

Gas Town already supports multiple runtime providers (Claude, Gemini, Codex, etc.), but users must manually specify which agent to use for each task. This creates friction and often leads to suboptimal model selection:

- **Over-spending**: Using Claude Opus for simple documentation tasks
- **Under-utilizing**: Not leveraging Perplexity for research or Gemini's 1M context for large codebases
- **Manual overhead**: Having to remember which model is best for each task type

The router solves this by automatically selecting the right model based on:
1. **Role** (mayor, polecat, deacon, etc.)
2. **Task labels** (research, review, test, etc.)
3. **Task properties** (bug priority, complexity markers)

## Implementation

### Architecture

```
gt sling issue rig
    │
    ▼
route-agent (default agent)
    │
    ├─► reads GT_ROLE env var
    ├─► loads config/models.yaml
    ├─► matches role → model
    │
    ▼
Spawns appropriate CLI (claude, gemini, perplexity, gpt4o, etc.)
```

### Files Added

```
bin/
└── route-agent          # Main router script (bash)

config/
└── models.yaml          # Model definitions and role mappings

agents/                  # Model-specific wrapper scripts
├── gemini-agent         # Gemini CLI wrapper with model selection
├── gemini-flash         # Pre-configured for gemini-2.5-flash
├── gemini-pro           # Pre-configured for gemini-2.5-pro
├── gpt4o                # GPT-4o via codex CLI or direct API
├── gpt4o-mini           # GPT-4o-mini for high-volume tasks
└── perplexity           # Perplexity API for web research
```

### Configuration Format (models.yaml)

```yaml
version: 1
default: claude-sonnet

models:
  claude-opus:
    cli: claude
    model_flag: opus
    capabilities: [code, reasoning, analysis]
    cost_tier: high

  claude-sonnet:
    cli: claude
    model_flag: sonnet
    capabilities: [code, reasoning]
    cost_tier: medium

  gemini-pro:
    cli: /path/to/agents/gemini-agent
    flags: ["--model", "gemini-2.5-pro"]
    capabilities: [code, reasoning, multimodal]
    cost_tier: medium

  perplexity:
    cli: /path/to/agents/perplexity
    capabilities: [research, web-search, citations]
    cost_tier: medium

  gpt-4o-mini:
    cli: /path/to/agents/gpt4o-mini
    capabilities: [simple-tasks, boilerplate, tests]
    cost_tier: low

roles:
  mayor: claude-opus        # Coordination needs strong reasoning
  deacon: claude-haiku      # Background monitoring - cost effective
  witness: claude-haiku     # Health checks - simple tasks
  refinery: claude-sonnet   # Merge queue - needs judgment
  polecat: claude-sonnet    # Code implementation - default
  research: perplexity      # Web research with citations
  review: gemini-pro        # Code review (large context)
  scaffolding: gpt-4o       # Boilerplate generation
  tests: gpt-4o-mini        # Unit test generation

task_overrides:
  - match:
      labels: ["research", "investigation"]
    model: perplexity

  - match:
      labels: ["test", "unit-test"]
    model: gpt-4o-mini

  - match:
      type: bug
      priority: [0, 1]
    model: claude-opus      # Critical bugs get best model
```

## Usage

### Setup

```bash
# Install as default agent
gt config agent set router /path/to/route-agent
gt config default-agent router

# Or use per-sling
gt sling issue rig --agent router
```

### Automatic Routing

Once configured as default, all spawns route automatically:

```bash
# Mayor spawns use Claude Opus
gt mayor attach

# Research tasks use Perplexity
bd create "Research OAuth providers" --labels research
gt sling ar-123 myrig  # Routes to Perplexity

# Code review uses Gemini Pro (1M context)
bd create "Review auth module" --labels review
gt sling ar-456 myrig  # Routes to Gemini Pro

# Test generation uses GPT-4o-mini (cheap, fast)
bd create "Add unit tests for utils" --labels test
gt sling ar-789 myrig  # Routes to GPT-4o-mini
```

### Manual Role Override

```bash
# Force a specific role routing
GT_ROLE=research ./route-agent "What are the rate limits for Stripe API?"
```

## Model Selection Strategy

| Role/Label | Model | Rationale |
|------------|-------|-----------|
| `mayor` | Claude Opus | Coordination requires strongest reasoning |
| `polecat`, `crew` | Claude Sonnet | Balanced capability for implementation |
| `deacon`, `witness` | Claude Haiku | Simple monitoring, cost-effective |
| `research` | Perplexity | Web search with citations |
| `review` | Gemini Pro | 1M token context for large PRs |
| `scaffolding` | GPT-4o | Good at structured output, boilerplate |
| `tests` | GPT-4o-mini | High volume, simple patterns |
| `documentation` | Claude Haiku | Straightforward writing tasks |
| P0/P1 bugs | Claude Opus | Critical issues get best model |

## Cost Optimization

Estimated savings with router vs. using Claude Sonnet for everything:

| Task Type | Before | After | Savings |
|-----------|--------|-------|---------|
| Monitoring (deacon/witness) | Sonnet | Haiku | ~80% |
| Test generation | Sonnet | GPT-4o-mini | ~90% |
| Documentation | Sonnet | Haiku | ~80% |
| Research | Sonnet | Perplexity | Better results + citations |

## Dependencies

- `yq` (YAML parser) - `brew install yq`
- API keys for desired providers:
  - `ANTHROPIC_API_KEY` or Claude CLI auth
  - `GEMINI_API_KEY` or Google login
  - `OPENAI_API_KEY` for GPT models
  - `PERPLEXITY_API_KEY` for research

## Future Enhancements

1. **Dynamic routing**: Read bead metadata to auto-detect task complexity
2. **Cost tracking**: Log model usage for spend analysis
3. **Fallback chains**: If primary model fails, try secondary
4. **Context-aware selection**: Route based on file count, code complexity
5. **User preferences**: Per-user model overrides in settings

## Testing

Tested with Gas Town v0.2.6 on macOS. Verified:
- [x] All built-in roles route correctly
- [x] Custom roles (research, review, scaffolding, tests) work
- [x] Task label overrides apply
- [x] Environment variables pass through to child CLIs
- [x] Works with `gt sling`, `gt mayor attach`, and direct invocation

## Breaking Changes

None. This is additive - existing setups continue to work unchanged.

## Related Issues

- Addresses use case for multi-model workflows
- Extends runtime configuration capabilities
- Complements existing agent preset system

---

**Author**: [Your Name]  
**Tested with**: Gas Town v0.2.6, beads v0.47.1  
**License**: MIT (same as Gas Town)
