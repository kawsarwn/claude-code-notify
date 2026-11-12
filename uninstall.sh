#!/bin/sh
set -eu
rm -rf "$HOME/.claude/ClaudeNotify.app"
rm -f "$HOME/.claude/hooks/claude-notify.sh"
rm -rf "$HOME/.claude/notify-queue"
rm -f "$HOME/.claude/notify-source"
echo "Removed ClaudeNotify. Remove the claude-notify.sh hooks from ~/.claude/settings.json too."
