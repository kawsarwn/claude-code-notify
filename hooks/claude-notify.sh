#!/bin/sh
# Claude Code hook: shows a macOS notification through ClaudeNotify.app.
# Reads the hook's JSON from stdin.

APP="${CLAUDE_NOTIFY_APP:-$HOME/.claude/ClaudeNotify.app}"
QUEUE="$HOME/.claude/notify-queue"

input=$(cat)
field() { printf '%s' "$input" | plutil -extract "$1" raw -o - - 2>/dev/null; }

event=$(field hook_event_name)
cwd=$(field cwd)
project=""
[ -n "$cwd" ] && project=$(basename "$cwd")

case "$event" in
  Stop) message="Claude finished"; sound="Glass" ;;
  *) message=$(field message); message=$(printf "%s" "$message" | tr "\n" " "); sound="Ping" ;;
esac
[ -n "$message" ] || message="Claude needs your attention"

if [ -n "${CLAUDE_NOTIFY_DRY_RUN:-}" ]; then
  printf '%s\n%s\n%s\n' "$project" "$sound" "$message"
  exit 0
fi

# Write to a hidden file, then rename, so the app never reads a half-written message.
mkdir -p "$QUEUE"
tmp=$(mktemp "$QUEUE/.XXXXXX") || exit 0
printf '%s\n%s\n%s\n' "$project" "$sound" "$message" > "$tmp"
msg="$QUEUE/$(date +%s)-${tmp##*/.}"
mv "$tmp" "$msg"
open -g -a "$APP" 2>/dev/null || rm -f "$msg"
exit 0
