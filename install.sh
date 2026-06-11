#!/bin/bash

set -euo pipefail

OPENCODE_CONFIG_DIR="$HOME/.config/opencode"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  Darwin) OS=macos ;;
  Linux)  OS=linux ;;
  *)      OS=unknown ;;
esac

echo "==> opencode-config setup (os: $OS)"

# Check opencode
if ! command -v opencode &>/dev/null; then
  echo "opencode not found. Install via:"
  echo "  npm install -g opencode-ai"
  echo "  # or (macOS): brew install anomalyco/tap/opencode"
  exit 1
fi

# Check snip (for opencode-snip plugin)
if ! command -v snip &>/dev/null; then
  echo "snip not found. Attempting install..."
  if command -v brew &>/dev/null; then
    brew install edouard-claude/tap/snip || echo "WARN: snip install failed; opencode-snip plugin will be inactive."
  else
    echo "WARN: brew not found. Install snip manually for the opencode-snip plugin:"
    echo "  https://github.com/edouard-claude/snip"
    echo "  Skipping — install will continue without snip."
  fi
fi

# Check uv (for memsearch)
if ! command -v uv &>/dev/null; then
  echo "uv not found. Installing..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  # uv installer drops binary in ~/.local/bin; make it visible this session
  [ -f "$HOME/.local/bin/env" ] && source "$HOME/.local/bin/env"
  export PATH="$HOME/.local/bin:$PATH"
fi

# Install memsearch
if ! command -v memsearch &>/dev/null; then
  if command -v uv &>/dev/null; then
    echo "==> Installing memsearch..."
    uv tool install 'memsearch[onnx]' || echo "WARN: memsearch install failed; @zilliz/memsearch-opencode plugin will be inactive."
  else
    echo "WARN: uv unavailable; skipping memsearch. Session-memory plugin will be inactive."
  fi
fi

# Install bun (required by open-ralph-wiggum)
if ! command -v bun &>/dev/null; then
  echo "bun not found. Installing..."
  curl -fsSL https://bun.sh/install | bash || echo "WARN: bun install failed; skipping open-ralph-wiggum."
  export PATH="$HOME/.bun/bin:$PATH"
fi

# Install open-ralph-wiggum CLI (autonomous agentic loop; external, not a plugin)
if ! command -v ralph &>/dev/null; then
  if command -v bun &>/dev/null; then
    echo "==> Installing open-ralph-wiggum (ralph)..."
    bun install -g @th0rgal/ralph-wiggum || echo "WARN: ralph install failed; autonomous loop CLI unavailable."
  else
    echo "WARN: bun unavailable; skipping open-ralph-wiggum."
  fi
fi

# Install ui-ux-pro-max skill (data-backed; uses its own CLI installer)
if command -v npx &>/dev/null; then
  echo "==> Installing ui-ux-pro-max skill for OpenCode..."
  npx -y uipro-cli init --ai opencode || echo "WARN: ui-ux-pro-max install failed; skill unavailable."
else
  echo "WARN: npx not found (Node.js 18+ required); skipping ui-ux-pro-max skill."
fi

if [ "$OS" = "linux" ]; then
  echo "NOTE: opencode-notify is macOS-only; task-completion notifications will not fire on Linux."
fi

# Create config dirs
mkdir -p "$OPENCODE_CONFIG_DIR/skills"
mkdir -p "$OPENCODE_CONFIG_DIR/commands"

# Backup existing config
if [ -f "$OPENCODE_CONFIG_DIR/opencode.json" ]; then
  BACKUP="$OPENCODE_CONFIG_DIR/opencode.json.bak.$(date +%Y%m%d%H%M%S)"
  echo "==> Backing up existing config to $BACKUP"
  cp "$OPENCODE_CONFIG_DIR/opencode.json" "$BACKUP"
fi

# Copy config
cp "$REPO_DIR/opencode.json" "$OPENCODE_CONFIG_DIR/opencode.json"
echo "==> Config installed"

# Sync skills (mirror repo -> remove orphans no longer in repo)
rsync -a --delete "$REPO_DIR/skills/" "$OPENCODE_CONFIG_DIR/skills/" 2>/dev/null \
  || cp -r "$REPO_DIR/skills/." "$OPENCODE_CONFIG_DIR/skills/"
echo "==> Skills installed"

# Sync commands (mirror repo -> remove orphans no longer in repo)
rsync -a --delete "$REPO_DIR/commands/" "$OPENCODE_CONFIG_DIR/commands/" 2>/dev/null \
  || cp -r "$REPO_DIR/commands/." "$OPENCODE_CONFIG_DIR/commands/"
echo "==> Commands installed"

echo ""
echo "Done. Next step: set your OpenRouter API key."
echo "  Start opencode, then run: /connect"
echo "  Select OpenRouter and paste your API key."
echo ""
echo "Get a key at: https://openrouter.ai/keys"
