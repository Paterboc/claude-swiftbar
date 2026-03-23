#!/bin/bash
# Claude Code statusline hook — writes rate limit data for the SwiftBar plugin
INPUT=$(cat)
DIR="/tmp/claude-statusline"
mkdir -p "$DIR"

SID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('session_id',''))" 2>/dev/null)
if [ -n "$SID" ]; then
  echo "$INPUT" > "$DIR/$SID.json"
fi

# Pass-through for Claude Code's built-in statusline
echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.loads(sys.stdin.read())
    rl = d.get('rate_limits', {})
    five = rl.get('five_hour', {}).get('used_percentage')
    week = rl.get('seven_day', {}).get('used_percentage')
    parts = []
    if five is not None: parts.append(f'5h:{five:.0f}%')
    if week is not None: parts.append(f'7d:{week:.0f}%')
    print(' '.join(parts) if parts else '')
except: pass
" 2>/dev/null
