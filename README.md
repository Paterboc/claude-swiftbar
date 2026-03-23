# Claude Code SwiftBar Plugin

A [SwiftBar](https://swiftbar.app) plugin that shows your Claude Code rate limit usage in the macOS menu bar.

```
 👾 8%|20%
 ├─ 5h session: 8.0%  resets 4h37m
 ├─ 7d weekly:  20.0%  resets 79h37m
 ├─ 2 active sessions
 ├─ Refresh
 └─ Quit SwiftBar
```

**Color-coded at a glance:**
- **Green** — under 50% usage
- **Yellow** — 50–80% usage
- **Red** — over 80% usage

## Install

**1. Install SwiftBar** (if you don't have it):

```bash
brew install --cask swiftbar
```

Open SwiftBar and set the plugin directory when prompted (default is fine).

**2. Run the installer:**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Paterboc/claude-swiftbar/main/install.sh)
```

This will:
- Copy the plugin to your SwiftBar plugins directory
- Install the Claude Code statusline hook at `~/.claude/statusline-command.sh`
- Add the `statusLine` config to `~/.claude/settings.json`

**3. Start using Claude Code.** Send any message and the menu bar will populate within 30 seconds.

> If you already have a running Claude Code session, restart it so the statusline hook takes effect.

## Requirements

- macOS
- [SwiftBar](https://swiftbar.app)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- Python 3

## Manual Install

If you prefer to install manually or already have a custom statusline:

**1. Install SwiftBar plugin**

```bash
cp claude-ctx.30s.sh ~/Library/Application\ Support/SwiftBar/Plugins/
chmod +x ~/Library/Application\ Support/SwiftBar/Plugins/claude-ctx.30s.sh
```

**2. Install the statusline hook**

```bash
cp statusline-command.sh ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
```

**3. Configure Claude Code**

Add this to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
  }
}
```

If you already have a custom `statusLine` command, you can chain them — just add the file-write logic from `statusline-command.sh` into your existing script.

## How It Works

1. Claude Code's statusline hook writes rate limit data to `/tmp/claude-statusline/` as JSON files (one per session)
2. The SwiftBar plugin reads the freshest data every 30 seconds and displays it in the menu bar
3. Rate limits are account-wide, so the plugin shows the highest usage across all sessions

## Customization

- **Refresh interval**: Rename the plugin file — the `30s` in the filename controls the interval (e.g., `claude-ctx.10s.sh` for 10 seconds)
- **Colors**: Edit the `color()` function thresholds in the plugin
- **Staleness**: Files older than 6 hours are ignored; adjust `21600` (seconds) in the plugin

## Uninstall

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Paterboc/claude-swiftbar/main/uninstall.sh)
```

Or run locally:

```bash
bash uninstall.sh
```

## License

MIT
