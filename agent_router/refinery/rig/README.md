# Agent Router

Multi-model routing layer for Gas Town agents.

## Purpose

Route different agent roles to different AI model backends:
- **Code implementation** (polecats) → Claude Sonnet
- **Coordination** (mayor) → Claude Opus
- **Monitoring** (witness, deacon) → Claude Haiku (cost-effective)
- **Research tasks** → Perplexity (web search)
- **Code review** → Gemini Pro

## Architecture

```
┌─────────────────────────────────────────────────┐
│                   Gas Town                       │
│  gt sling → agent-router → model-specific CLI   │
└─────────────────────────────────────────────────┘
```

This is a **non-invasive layer** that works alongside `gt` without modifying it.

## Installation

Register the router as a custom agent:

```bash
gt config agent set router /path/to/agent_router/bin/route-agent
```

## Usage

Use the router when slinging work:

```bash
# Explicit router usage
gt sling issue rig --agent router

# The router reads GT_ROLE from environment and routes accordingly:
# - polecat → claude --model sonnet
# - witness → claude --model haiku
# - mayor   → claude --model opus
```

### Testing

Test routing locally with different roles:

```bash
GT_ROLE=polecat ./bin/route-agent --help
# → claude --dangerously-skip-permissions --model sonnet

GT_ROLE=witness ./bin/route-agent --help
# → claude --dangerously-skip-permissions --model haiku

GT_ROLE=mayor ./bin/route-agent --help
# → claude --dangerously-skip-permissions --model opus
```

## Configuration

See `config/models.yaml` for role → model mappings.

### Default Mappings

| Role | Model | Rationale |
|------|-------|-----------|
| mayor | claude-opus | Coordination requires strong reasoning |
| deacon | claude-haiku | Background monitoring - cost effective |
| witness | claude-haiku | Health checks - simple tasks |
| refinery | claude-sonnet | Merge queue - needs good judgment |
| polecat | claude-sonnet | Code implementation - default |
| crew | claude-sonnet | Human-managed workers |

## Dependencies

- `yq` - YAML parser (`brew install yq`)
