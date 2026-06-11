# opencode-config

Shared OpenCode configuration with OpenRouter integration, curated plugin stack, and caveman skill.

## Requirements

- macOS or Linux
- Node.js 18+
- Homebrew (macOS; optional on Linux — only used to auto-install `snip`)

On Linux `snip` is not auto-installed without Homebrew; install it manually
(https://github.com/edouard-claude/snip) or the `opencode-snip` plugin stays
inactive. `opencode-notify` is macOS-only and is a no-op on Linux. Everything
else installs the same on both.

## Installation

```bash
git clone https://github.com/YOUR-ORG/opencode-config.git
cd opencode-config
chmod +x install.sh
./install.sh
```

The script automatically installs:
- `snip` (token reduction for shell output) — via Homebrew; non-fatal if unavailable
- `uv` + `memsearch` (local vector database for session memory) — non-fatal if install fails
- `bun` + `ralph` ([open-ralph-wiggum](https://github.com/Th0rgal/open-ralph-wiggum) autonomous loop CLI) — non-fatal if install fails
- `ui-ux-pro-max` skill via `npx uipro-cli init --ai opencode` — non-fatal if install fails
- Config, skills, and commands into `~/.config/opencode/`

Only a missing `opencode` binary aborts the install; everything else degrades to a
warning and the matching plugin stays inactive. Detects macOS vs Linux automatically.

## Autonomous loops (ralph)

[open-ralph-wiggum](https://github.com/Th0rgal/open-ralph-wiggum) is installed as an
external CLI (`ralph`), not a plugin. It re-feeds the same prompt until a completion
promise is hit:

```bash
ralph "Build feature X. Output <promise>DONE</promise> when complete." --agent opencode
ralph --help                 # all flags (--max-iterations, --no-plugins, etc.)
```

Bounded by `--completion-promise` and `--max-iterations`. Combined with the
`opencode-yolo` plugin (auto-approve), it runs fully unattended — set iteration
caps and review the resulting commits.

## Set up API key

After installation, start OpenCode and connect your OpenRouter key:

```bash
opencode
# In the TUI: /connect -> OpenRouter -> paste API key
```

Create a key at: https://openrouter.ai/keys

## Included models

| Model | Use case |
|---|---|
| Claude Sonnet 4.6 | Standard coding (default) |
| Claude Opus 4.8 | Complex tasks, large codebases |
| Claude Haiku 4.5 | Fast tasks, sub-agents (small_model) |
| DeepSeek V4 Flash | 1M context, very cheap |
| Qwen3 Coder (free) | Free, budget fallback |

Switch model in the TUI: `Ctrl+M`

## Included plugins

| Plugin | Function |
|---|---|
| `envsitter-guard` | Protects .env files from LLM access |
| `cc-safety-net` | Blocks destructive git/shell commands |
| `@frankhommers/opencode-yolo` | Auto mode, no manual approvals |
| `@zilliz/memsearch-opencode` | Session memory via local vector database |
| `opencode-dynamic-context-pruning` | Reduces context consumption automatically |
| `opencode-snip` | Trims shell output by 60-90% |
| `opencode-notify` | macOS notification on task completion (no-op on Linux) |

## Included skills

- **caveman**: Token-saving communication mode (`/caveman`, `/caveman ultra`, `/caveman off`)
- **design-taste-frontend**: Anti-slop frontend skill for landing pages, portfolios, and redesigns ([Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill))
- **karpathy-guidelines**: Behavioral guidelines to reduce common LLM coding mistakes ([multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills))
- **test-driven-development**: Red-green-refactor discipline; write tests before implementation ([obra/superpowers](https://github.com/obra/superpowers))
- **systematic-debugging**: Root-cause-first debugging, no shotgun fixes ([obra/superpowers](https://github.com/obra/superpowers))
- **brainstorming**: Explore intent and design before writing code ([obra/superpowers](https://github.com/obra/superpowers))
- **verification-before-completion**: Run verification and confirm output before claiming work done ([obra/superpowers](https://github.com/obra/superpowers))
- **requesting-code-review**: Structured review pass before merging (uses sub-agents) ([obra/superpowers](https://github.com/obra/superpowers))
- **api-design-reviewer**: REST API design review, breaking-change detection, scorecards ([alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills))

## Directory structure

```
opencode-config/
  opencode.json       <- Main configuration
  install.sh          <- Setup script
  skills/
    caveman/
      SKILL.md
  commands/
    caveman.md
```

## Update config

```bash
git pull
./install.sh
```

Existing `opencode.json` is automatically backed up with a timestamp. Skills and
commands are mirrored with `rsync --delete`, so anything removed from the repo is
also removed from `~/.config/opencode/` — don't keep local-only skills there.
