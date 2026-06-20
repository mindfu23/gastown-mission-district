# Gemini Agent Setup for Gastown

This guide covers setting up and using Gemini agents in your Gastown workspace.

## Quick Start

### 1. Authenticate with Gemini

The easiest way is to log in with your Google account:

```bash
gemini
# Select "Login with Google" when prompted
# Complete authentication in your browser
```

Alternatively, use an API key:

```bash
# Get a key from https://aistudio.google.com/apikey
export GEMINI_API_KEY="your-api-key-here"

# Add to shell config for persistence:
echo 'export GEMINI_API_KEY="your-api-key"' >> ~/.zshrc
```

### 2. Available Gemini Agents

| Agent | Model | Best For |
|-------|-------|----------|
| `gemini` | gemini-2.5-pro | Default, balanced capability |
| `gemini-flash` | gemini-2.5-flash | Fast, cheap, simple tasks |
| `gemini-pro` | gemini-2.5-pro | Complex reasoning, large context |

### 3. Using Gemini Agents

```bash
# Use gemini-flash for a cost-efficient task
gt sling myissue myrig --agent gemini-flash

# Use gemini-pro for complex work
gt sling complex-refactor myrig --agent gemini-pro

# Use the default gemini agent
gt sling myissue myrig --agent gemini
```

## Cost Optimization Strategy

For multi-agent workflows, consider:

1. **Triage with Flash**: Use `gemini-flash` for initial analysis, quick fixes, documentation
2. **Deep work with Pro**: Use `gemini-pro` for architecture decisions, complex debugging
3. **Mix with Claude**: Claude for nuanced writing, Gemini for code analysis

Example convoy setup:
```bash
# Quick tasks with flash
gt sling doc-updates myrig --agent gemini-flash
gt sling lint-fixes myrig --agent gemini-flash

# Complex tasks with pro or claude
gt sling refactor-auth myrig --agent gemini-pro
gt sling api-design myrig --agent claude
```

## Free Tier Limits

With a personal Google account (no payment required):
- 60 requests per minute
- 1,000 requests per day
- Access to Gemini 2.5 Pro with 1M token context

## Environment Variables

| Variable | Description |
|----------|-------------|
| `GEMINI_API_KEY` | API key (alternative to Google login) |
| `GEMINI_MODEL` | Default model for gemini-agent wrapper |
| `GEMINI_SESSION_ID` | Session ID (set by Gastown) |
| `GOOGLE_CLOUD_PROJECT` | Required for Vertex AI auth |
| `GOOGLE_CLOUD_LOCATION` | Required for Vertex AI auth |

## Custom Agent Scripts

The custom agents are located in `agents/`:

```
agents/
├── gemini-agent     # Base wrapper with model selection
├── gemini-flash     # Pre-configured for 2.5 Flash
└── gemini-pro       # Pre-configured for 2.5 Pro
```

To create your own variant:

```bash
#!/bin/bash
# agents/gemini-custom
export GEMINI_MODEL="gemini-2.0-flash"  # Your preferred model
exec "$(dirname "$0")/gemini-agent" --approval-mode yolo "$@"
```

Then register it:
```bash
gt config agent set gemini-custom "/path/to/gastown/agents/gemini-custom"
```

## Troubleshooting

### "Not authenticated" error
```bash
# Re-authenticate
gemini
# Follow the browser login flow
```

### API rate limits
Switch to a cheaper model or wait for quota reset:
```bash
gt sling myissue myrig --agent gemini-flash
```

### Session issues
```bash
# List and clean up sessions
gemini --list-sessions
gemini --delete-session <index>
```
