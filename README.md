# cc-provider-switch

Switch [Claude Code](https://docs.anthropic.com/en/docs/claude-code) API providers instantly — Anthropic, LiteLLM, Ollama, or any OpenAI-compatible proxy.

## How It Works

Each provider is a JSON file in `providers/` that defines environment variables and settings overrides. When you switch, the tool backs up your current settings, clears previous provider config, and applies the new provider's values.

## Install

Requires [`jq`](https://stedolan.github.io/jq/).

**One-liner:**
```bash
curl -fsSL https://raw.githubusercontent.com/elmuhammadcholidh/cc-provider-switch/main/install.sh | bash
```

**Manual:**
```bash
git clone https://github.com/elmuhammadcholidh/cc-provider-switch.git ~/cc-provider-switch
cd ~/cc-provider-switch && make install
```

## Usage

```bash
cc-switch                     # Interactive menu
cc-switch anthropic            # Switch to Anthropic directly
cc-switch status               # Show current provider
cc-switch list                 # List all providers
cc-switch validate             # Validate all provider configs
cc-switch check                # Health check all providers
cc-switch check anthropic      # Health check specific provider
cc-switch rollback             # Undo last switch

# Project-specific settings
cc-switch -p ~/myproject ollama      # Switch project to Ollama
cc-switch -p ~/myproject status      # Check project's active provider
cc-switch -p ~/myproject rollback    # Rollback project settings
```

### Shell Completions

```bash
# Bash
echo 'source ~/cc-provider-switch/completions/cc-switch.bash' >> ~/.bashrc

# Zsh
echo 'source ~/cc-provider-switch/completions/cc-switch.zsh' >> ~/.zshrc
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

See `providers/examples/` for more.

> **Note:** Provider files may contain API tokens. Add them to `.gitignore` or copy from examples and edit locally.

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
| `cliproxyapi` | CliproxyAPI local gateway | Yes |
| `openrouter` | OpenRouter API | Yes |
| `cerebras` | Cerebras API | Yes |
| `groq` | Groq API | Yes |
| `z-ai` | Z.ai API | Yes |

## Development

Run tests with [BATS](https://github.com/bats-core/bats-core):

```bash
bats test/
```

## License

MIT
