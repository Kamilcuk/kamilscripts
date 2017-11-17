#!/bin/sh
set -euo pipefail

saddunit=""
saddservice=""
saddexecstart=""

echo "Please answer the following questions:"
if [ $# -eq 0 ]; then
	read -e -p "Timer/service name? " name
	if [ -z "$name" ]; then echo "Error: name is empty! " >&2; exit 1; fi;
elif [ $# -eq 1 ]; then
	name=$1
	echo "Timer/service name? $name"
else
	echo "ERROR: too many arguments;" >&2; exit 1;
fi
d="Run $name";       read -e -p "Service description string? default: '$d' "  ssdesc      ; : ${sdesc:=$d}
d="/usr/bin/$name";  read -e -p "Service ExecStart? default: '$d' "           sexec       ; : ${sexec:=$d}
d="Daily";           read -e -p "OnCalendar timer? default: '$d' "            toncalendar ; : ${toncalendar:=$d}
d="$toncalendar $name run"; read -e -p "Timer description string? default: '$d' " tdesc   ; : ${tdesc:=$d}

read -e -p "Add args from config file /etc/$name.conf to service? [y*|*] default: 'no' " ans ; : ${ans:=no}
case $ans in 
	[Yy]*) echo "Adding $condpath and $envpath..."; 
		saddunit+="ConditionPathExists = /etc/$name.conf"$'\n'; 
		saddexecstart+="\$args"
		saddservice+="EnvironmentFile = /etc/$name.conf"$'\n';
		;;
	*) ;;
esac

# Generation ###########################################################

tout=/tmp/$name.timer
echo "Generating $tout ..."
printf '[Unit]
Description = %s

[Timer]
OnCalendar = %s
AccuracySec = 1d
Persistent = true

[Install]
WantedBy = multi-user.target
' "$tdesc" "$toncalendar" > "$tout"

sout=/tmp/$name.service
echo "Generating $sout ..."
printf '[Unit]
Description = %s
'"$saddunit"'
[Service]
Type = oneshot
ExecStart = %s '"$saddexecstart"'
'"$saddservice"'
' "$sdesc" "$sexec" > "$sout"
echo "DONE!"

