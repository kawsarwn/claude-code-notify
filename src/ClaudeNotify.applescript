-- Shows every message waiting in ~/.claude/notify-queue, then quits.
-- Each file holds three lines: subtitle, sound name, message.
-- Launched with an empty queue means the user clicked a notification: open the app Claude runs in.

property lastShown : missing value

on run
	drain()
end run

on reopen
	drain()
end reopen

on drain()
	set total to 0
	repeat
		set shown to showQueued()
		if shown is 0 then exit repeat
		set total to total + shown
		set lastShown to current date
		-- macOS can drop a banner if the app quits right after posting it
		delay 1
	end repeat
	-- a hook's launch can arrive just after its message was already shown, so only treat it as a click when nothing was shown recently
	if total is 0 and (lastShown is missing value or ((current date) - lastShown) > 3) then
		do shell script "id=$(cat ~/.claude/notify-source 2>/dev/null); [ -n \"$id\" ] && open -b \"$id\" || true"
	end if
end drain

on showQueued()
	set q to POSIX path of (path to home folder) & ".claude/notify-queue"
	set names to paragraphs of (do shell script "ls " & quoted form of q & " 2>/dev/null | sort || true")
	set shown to 0
	repeat with n in names
		if (n as text) is not "" then
			set p to q & "/" & n
			set lns to paragraphs of (do shell script "cat " & quoted form of p & " 2>/dev/null; rm -f " & quoted form of p)
			if (count of lns) ≥ 3 then
				set sub to item 1 of lns
				set snd to item 2 of lns
				set msg to item 3 of lns
				if snd is "" then
					display notification msg with title "Claude Code" subtitle sub
				else
					display notification msg with title "Claude Code" subtitle sub sound name snd
				end if
				set shown to shown + 1
			end if
		end if
	end repeat
	return shown
end showQueued
