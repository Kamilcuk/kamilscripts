#!/bin/sh
set -euo pipefail

echo "Please answer the following questions:"
read -e -p "Timer/service name? " name
if [ -z "$name" ]; then echo "Error: name is empty! " >&2; exit 1; fi;
d="Run $name";       read -e -p "Service description string? default: '$d' "  ssdesc      ; : ${sdesc:=$d}
d="/usr/bin/$name";  read -e -p "Service ExecStart? default: '$d' "           sexec       ; : ${sexec:=$d}
d="Daily";           read -e -p "OnCalendar timer? default: '$d' "            toncalendar ; : ${toncalendar:=$d}
d="$toncalendar $name run"; read -e -p "Timer description string? default: '$d' " tdesc   ; : ${tdesc:=$d}

tout=/tmp/$name.timer
echo "Generating $tout ..."
printf '[Unit]
Description = %s

[Timer]
OnCalendar=%s
AccuracySec=1d
Persistent=true
' "$tdesc" "$toncalendar" > "$tout"

sout=/tmp/$name.service
echo "Generating $sout ..."
printf '[Unit]
Description = %s

[Service]
Type = oneshot
ExecStart = %s
' "$sdesc" "$sexec" > "$sout"
echo "DONE!"

