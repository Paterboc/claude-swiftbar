#!/bin/bash
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>

# Claude Code rate limit monitor for SwiftBar/xbar
# Shows 5-hour session and 7-day weekly usage in your menu bar

python3 << 'PYEOF'
import json, os, glob, time, subprocess

DIR = "/tmp/claude-statusline"

try:
    num_sessions = len(subprocess.check_output(
        ["pgrep", "-x", "claude"], text=True, stderr=subprocess.DEVNULL
    ).strip().split("\n"))
except subprocess.CalledProcessError:
    num_sessions = 0

if not num_sessions:
    print("\U0001F47E -- | color=#666666 size=13")
    print("---")
    print("No Claude sessions | color=#888888")
    raise SystemExit(0)

five_pct = None
week_pct = None
five_reset = None
week_reset = None

now = time.time()
files = [(os.path.getmtime(f), f) for f in glob.glob(os.path.join(DIR, "*.json"))]
files.sort(reverse=True)

for mtime, path in files:
    if now - mtime > 21600:
        break
    try:
        with open(path) as f:
            d = json.load(f)
        rl = d.get("rate_limits", {})
        fh = rl.get("five_hour", {})
        sd = rl.get("seven_day", {})
        fp = fh.get("used_percentage")
        wp = sd.get("used_percentage")
        if fp is not None and (five_pct is None or fp > five_pct):
            five_pct = fp
            five_reset = fh.get("resets_at")
        if wp is not None and (week_pct is None or wp > week_pct):
            week_pct = wp
            week_reset = sd.get("resets_at")
    except (json.JSONDecodeError, IOError):
        continue

if five_pct is None and week_pct is None:
    print(f"\U0001F47E {num_sessions}s | color=#888888 size=13")
    print("---")
    print("Waiting for usage data... | color=#888888")
    print("Send a message in Claude to populate | color=#666666 size=11")
    raise SystemExit(0)

def color(p):
    if p is None: return "#888888"
    if p < 50: return "#00d4a8"
    if p < 80: return "#ffcc00"
    return "#e03868"

def reset_str(ts):
    if ts is None: return ""
    diff = ts - time.time()
    if diff <= 0: return "now"
    h = int(diff // 3600)
    m = int((diff % 3600) // 60)
    if h > 0: return f"{h}h{m}m"
    return f"{m}m"

def print_limit(label, pct, reset_ts):
    r = reset_str(reset_ts)
    rtext = f"  resets {r}" if r else ""
    print(f"{label}: {pct:.1f}%{rtext} | color={color(pct)}")

top_color = color(max(five_pct or 0, week_pct or 0))
print(f"\U0001F47E {five_pct:.0f}%|{week_pct:.0f}% | color={top_color} size=13")

print("---")
if five_pct is not None: print_limit("5h session", five_pct, five_reset)
if week_pct is not None: print_limit("7d weekly ", week_pct, week_reset)
print("---")
print(f"{num_sessions} active session{'s' if num_sessions > 1 else ''} | color=#888888 size=11")
print("Refresh | refresh=true")
print("---")
print("Quit SwiftBar | bash=osascript param1=-e param2='tell application \"SwiftBar\" to quit' terminal=false")
PYEOF
