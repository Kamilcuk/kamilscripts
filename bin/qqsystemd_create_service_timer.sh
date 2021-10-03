#!/bin/bash
set -euo pipefail

saddunit=""
saddservice=""
#saddexecstart=""

echo "Please answer the following questions:"
if [ $# -eq 0 ]; then
	read -r -e -p "Timer/service name? " name
	if [ -z "$name" ]; then echo "Error: name is empty! " >&2; exit 1; fi;
elif [ $# -eq 1 ]; then
	name=$1
	echo "Timer/service name? $name"
else
	echo "ERROR: too many arguments;" >&2; exit 1;
fi
d="Run $name";       read -r -e -p "Service description string? default: '$d' "  sdesc      ; : "${sdesc:=$d}"
d="/usr/bin/$name";  read -r -e -p "Service ExecStart? default: '$d' "           sexec       ; : "${sexec:=$d}"
d="Daily";           read -r -e -p "OnCalendar timer? default: '$d' "            toncalendar ; : "${toncalendar:=$d}"
d="Run $name $toncalendar"; read -r -e -p "Timer description string? default: '$d' " tdesc   ; : "${tdesc:=$d}"

read -r -e -p "Add args from config file /etc/$name.conf to service? [y*|*] default: 'no' " ans ; : "${ans:=no}"
case $ans in 
	[Yy]*) echo "Adding ConditionPathExists and EnvironmentFile..."; 
		saddunit+="ConditionPathExists = /etc/$name.conf"$'\n'; 
		sexec+=" \$args"
		saddservice+="EnvironmentFile = /etc/$name.conf"$'\n';
		;;
	*) ;;
esac

# Generation ###########################################################

tout=/tmp/$name.timer
echo "Generating $tout ..."
cat > "$tout" <<EOF
[Unit]
Description=$tdesc

[Timer]
OnCalendar=$toncalendar
AccuracySec=1d
Persistent=true

[Install]
WantedBy=multi-user.target
EOF

sout=/tmp/$name.service
echo "Generating $sout ..."
cat > "$sout" <<EOF
[Unit]
Description=$sdesc
$saddunit
[Service]
Type=oneshot
ExecStart=$sexec
$saddservice

[Install]
WantedBy=multi-user.target
EOF
echo "DONE!"

