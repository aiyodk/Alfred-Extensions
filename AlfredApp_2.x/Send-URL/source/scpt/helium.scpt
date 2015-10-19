on run argv
set appname to "Helium"
tell application appname to launch
tell application "System Events"
repeat until visible of process appname is true
	delay 0.5
end repeat
end tell
delay 2
do shell script "Open helium://" & quoted form of item 1 of argv
end run