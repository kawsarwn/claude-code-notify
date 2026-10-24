-- Shows every message waiting in ~/.claude/notify-queue, then quits.
-- Each file holds three lines: subtitle, sound name, message.
on run
	set q to POSIX path of (path to home folder) & ".claude/notify-queue"
	repeat
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
		-- wait for messages that arrive while we're running; macOS can also drop a banner if the app quits right after posting it
		delay 1
		if shown is 0 then exit repeat
	end repeat
end run
