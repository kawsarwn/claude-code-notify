#!/bin/sh
# Checks the hook's parsing and that the AppleScript compiles. Sends no notifications.
set -u
cd "$(dirname "$0")"
fail=0

check() {
  got=$(printf '%s' "$2" | CLAUDE_NOTIFY_DRY_RUN=1 sh hooks/claude-notify.sh | tr '\n' '|')
  if [ "$got" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1: got '$got', want '$3'"; fail=1; fi
}

check "stop" '{"hook_event_name":"Stop","cwd":"/Users/me/code/my-app"}' 'my-app|Glass|Claude finished|'
check "permission" '{"hook_event_name":"Notification","cwd":"/x/api","message":"Claude needs your permission to use Bash"}' 'api|Ping|Claude needs your permission to use Bash|'
check "idle" '{"hook_event_name":"Notification","cwd":"/x/api","message":"Claude is waiting for your input"}' 'api|Ping|Claude is waiting for your input|'
check "quotes" '{"hook_event_name":"Notification","cwd":"/x/a b","message":"Use \"rm\"? it'"'"'s fine"}' "a b|Ping|Use \"rm\"? it's fine|"
check "multiline" '{"hook_event_name":"Notification","cwd":"/x/api","message":"line one\nline two"}' 'api|Ping|line one line two|'
check "no message" '{"hook_event_name":"Notification"}' '|Ping|Claude needs your attention|'
check "bad json" 'not json' '|Ping|Claude needs your attention|'

tmp=$(mktemp -d)
if osacompile -o "$tmp/t.app" src/ClaudeNotify.applescript 2>/dev/null; then echo "ok   applescript compiles"; else echo "FAIL applescript compiles"; fail=1; fi
rm -rf "$tmp"

exit $fail
