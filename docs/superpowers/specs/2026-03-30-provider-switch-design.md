# cc-provider-switch Design

## Overview
CLI tool to switch between Claude Code API providers by managing environment variables in `~/.claude/settings.json`.

## Requirements
- Store provider configs as separate JSON files
- Support both interactive menu and direct CLI args
- Keep tokens in provider config files (chmod 600)
- Backup settings before each switch

## Project Structure
```
~/Repositories/Personal/cc-provider-switch/
├── providers/
│   ├── anthropic.json      # Default Anthropic
│   ├── z-ai.json           # z.ai fallback
│   ├── ollama.json         # Local Ollama
│   ├── litellm.json        # LiteLLM
│   └── cliproxyapi.json    # CliproxyAPI
├── cc-switch              # Main CLI script (symlinked to ~/.local/bin)
└── README.md
```

## Provider Config Schema
```json
{
  "name": "display-name",
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "...",
    "ANTHROPIC_BASE_URL": "...",
    "API_TIMEOUT_MS": "...",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "...",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "...",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "..."
  }
}
```

## CLI Interface
```
cc-switch [provider]   Switch to provider (interactive if no arg)
cc-switch status         Show current provider
cc-switch list           List available providers
cc-switch --help         Show help
```

## Behavior
1. No args: Show interactive menu (fzf or numbered list)
2. With arg: Switch directly to that provider
3. Switching: Merge provider env into settings.json env, preserving non-conflicting keys
4. Always backup before modification

## Security
- Provider files chmod 600 (owner read/write only)
- Config dir chmod 700
