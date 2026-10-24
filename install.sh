#!/bin/sh
# Builds ClaudeNotify.app and installs the Claude Code hook script.
set -eu
cd "$(dirname "$0")"

APP="$HOME/.claude/ClaudeNotify.app"
HOOK="$HOME/.claude/hooks/claude-notify.sh"
BUNDLE_ID="io.github.kawsarwn.claude-notify"
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister

[ "$(uname)" = "Darwin" ] || { echo "ClaudeNotify only works on macOS." >&2; exit 1; }

mkdir -p "$HOME/.claude/hooks"
rm -rf "$APP"
osacompile -o "$APP" src/ClaudeNotify.applescript

# osacompile ships a default icon catalog named "applet"; a distinct icon name
# keeps macOS from picking that one over ours.
cp assets/ClaudeNotify.icns "$APP/Contents/Resources/ClaudeNotify.icns"
plist="$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIconFile ClaudeNotify" "$plist"
/usr/libexec/PlistBuddy -c "Delete :CFBundleIconName" "$plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$plist" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $BUNDLE_ID" "$plist"
/usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" "$plist" 2>/dev/null || true

codesign --force --deep --sign - "$APP" >/dev/null 2>&1
touch "$APP"
"$LSREGISTER" -f "$APP"

cp hooks/claude-notify.sh "$HOOK"
chmod +x "$HOOK"

echo '{"hook_event_name":"Notification","message":"Notifications are working."}' | "$HOOK"

cat <<MSG
Installed:
  $APP
  $HOOK

A test notification was just sent. If macOS asks, allow notifications for ClaudeNotify.

Last step: add the hooks to ~/.claude/settings.json (see README.md):

  "hooks": {
    "Notification": [{ "hooks": [{ "type": "command", "command": "~/.claude/hooks/claude-notify.sh" }] }],
    "Stop":         [{ "hooks": [{ "type": "command", "command": "~/.claude/hooks/claude-notify.sh" }] }]
  }
MSG
