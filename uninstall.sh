#!/bin/bash
set -e

# Claude Code SwiftBar Plugin — Uninstaller

PLUGIN_DIR="$HOME/Library/Application Support/SwiftBar/Plugins"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
HOOK_PATH="$CLAUDE_DIR/statusline-command.sh"

echo "Removing SwiftBar plugin..."
rm -f "$PLUGIN_DIR/claude-ctx.30s.sh"

echo "Removing statusline hook..."
rm -f "$HOOK_PATH"

echo "Cleaning up statusline data..."
rm -rf /tmp/claude-statusline

if [ -f "$SETTINGS" ]; then
  echo "Removing statusLine config from settings..."
  python3 -c "
import json
with open('$SETTINGS') as f:
    s = json.load(f)
s.pop('statusLine', None)
with open('$SETTINGS', 'w') as f:
    json.dump(s, f, indent=2)
    f.write('\n')
" 2>/dev/null || true
fi

echo ""
echo "Uninstalled. Restart SwiftBar to remove the menu bar item."
