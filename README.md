# cc-provider-switch

Switch [Claude Code](https://docs.anthropic.com/en/docs/claude-code) API providers instantly —Anthropic, LiteLLM, Ollama, or any OpenAI-compatible proxy.

## How It Works

Each provider is a JSON file in `providers/` that defines environment variables and settings overrides. When you switch, the tool:

1. Backs up your current `~/.claude/settings.json`
2. Removes all provider-managed keys from settings
3. Applies the new provider's env vars and settings
4. Tracks the active provider in `config.json`

## Install

```bash
# Clone
git clone https://github.com/youruser/cc-provider-switch.git ~/cc-provider-switch

# Symlink to PATH
ln -sf ~/cc-provider-switch/cc-switch ~/.local/bin/cc-switch

# Create your config
cp config.example.json config.json
```

Requires [`jq`](https://stedolan.github.io/jq/).

## Usage

```bash
cc-switch                # Interactive menu
cc-switch anthropic      # Switch to Anthropic directly
cc-switch status         # Show active provider
cc-switch list           # List all providers

# Project-specific settings
cc-switch -p ~/myproject ollama      # Switch project to Ollama
cc-switch -p ~/myproject status      # Check project's active provider
```

## Adding Providers

Create `providers/<name>.json`:

```json
{
  "name": "my-provider",
  "description": "My custom provider",
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.example.com/v1",
    "ANTHROPIC_AUTH_TOKEN": "your-token",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "model-name",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "model-name",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "model-name"
  },
  "settings": {
    "model": "opus"
  }
}
```

Optional fields:
- `settings` — overrides for Claude Code's `settings.json` (e.g. `"model": "opus[1m]"`)
- `env` — any environment variables injected into Claude Code's settings

See `providers/examples/` for more examples.

### Protecting API Tokens

Add token-bearing providers to `.gitignore`:

```gitignore
providers/my-provider.json
```

Or copy from examples:

```bash
cp providers/examples/z-ai.example.json providers/z-ai.json
# Edit with your real token
```

## Included Providers

| Provider | Description | Requires Token |
|----------|-------------|---------------|
| `anthropic` | Default Anthropic API | Yes (via `ANTHROPIC_API_KEY`) |
| `ollama` | Local Ollama | No |
| `litellm` | LiteLLM proxy | Varies |
| `cliproxyapi` | CliproxyAPI proxy | Yes |

## License

MIT
