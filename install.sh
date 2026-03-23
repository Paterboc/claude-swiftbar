#!/bin/bash
set -e

# Claude Code SwiftBar Plugin — Installer
# Installs the menu bar plugin and configures Claude Code's statusline hook.

REPO_URL="https://raw.githubusercontent.com/Paterboc/claude-swiftbar/main"
PLUGIN_DIR="$HOME/Library/Application Support/SwiftBar/Plugins"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
HOOK_PATH="$CLAUDE_DIR/statusline-command.sh"

# ── Preflight ─────────────────────────────────────────────────────────────────

if [[ "$(uname)" != "Darwin" ]]; then
  echo "Error: This plugin is macOS only."
  exit 1
fi

if ! command -v python3 &>/dev/null; then
  echo "Error: python3 is required."
  exit 1
fi

if [ ! -d "$PLUGIN_DIR" ]; then
  echo "SwiftBar not found. Install it from https://swiftbar.app and run this script again."
  echo ""
  echo "  brew install --cask swiftbar"
  echo ""
  exit 1
fi

# ── Install plugin ────────────────────────────────────────────────────────────

echo "Installing SwiftBar plugin..."
if [ -f "$0" ] && [ -f "$(dirname "$0")/claude-ctx.30s.sh" ]; then
  # Running from cloned repo
  cp "$(dirname "$0")/claude-ctx.30s.sh" "$PLUGIN_DIR/claude-ctx.30s.sh"
  cp "$(dirname "$0")/statusline-command.sh" "$HOOK_PATH"
else
  # Running via curl
  curl -fsSL "$REPO_URL/claude-ctx.30s.sh" -o "$PLUGIN_DIR/claude-ctx.30s.sh"
  curl -fsSL "$REPO_URL/statusline-command.sh" -o "$HOOK_PATH"
fi

chmod +x "$PLUGIN_DIR/claude-ctx.30s.sh"
chmod +x "$HOOK_PATH"

# ── Configure Claude Code statusline ──────────────────────────────────────────

echo "Configuring Claude Code statusline..."
mkdir -p "$CLAUDE_DIR"

if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

# Add statusLine config if not already present
if python3 -c "
import json, sys
with open('$SETTINGS') as f:
    s = json.load(f)
if 'statusLine' in s:
    sys.exit(1)
" 2>/dev/null; then
  python3 -c "
import json
with open('$SETTINGS') as f:
    s = json.load(f)
s['statusLine'] = {
    'type': 'command',
    'command': 'bash ~/.claude/statusline-command.sh'
}
with open('$SETTINGS', 'w') as f:
    json.dump(s, f, indent=2)
    f.write('\n')
"
  echo "  Added statusLine to $SETTINGS"
else
  echo "  statusLine already configured in $SETTINGS — skipping."
  echo "  If you have a custom statusLine command, see the README for manual setup."
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Done! The plugin will appear in your menu bar on the next SwiftBar refresh."
echo "Send a message in any Claude Code session to populate usage data."
