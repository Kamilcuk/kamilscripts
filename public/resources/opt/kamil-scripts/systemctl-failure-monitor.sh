#!/bin/bash
# Written by Kamil Cukrowski (C) 2017. Under MIT License
#

set -euo pipefail

TEST=${TEST:-false}

# functions ###################################

usage() {
	n=systemctl-failure-monitor.sh
	cat <<EOF
Usage:  $n [options] <email address>

Options:
	-i, --ignore <name> - ignore services that match name
        -d, --no-duplicate  - don't send email on duplicated fails

Scirpt monitors journalctl for failed jobs/services.
In case of a failed job/service, it sends email to designated address.

Example:
	$n your_email@gmail.com

Written by Kamil Cukrowski (C) 2017. Under MIT License
EOF
}

if $TEST; then
	journalctl() { 
	while read line; do echo $line; sleep 0.2; done <<EOF
sie 18 12:34:39 systemd[1]: systemd-fsck@dev-disk-by\x2dlabel-DYSK_D.service: Job systemd-fsck@dev-disk-by\x2dlabel-DYSK_D.service/start failed with result 'dependency'.
sie 18 12:34:39 systemd[1]: dev-disk-by\x2dlabel-DYSK_D.device: Job dev-disk-by\x2dlabel-DYSK_D.device/start failed with result 'timeout'.
sie 18 12:34:39 systemd[1]: mnt-windows.mount: Job mnt-windows.mount/start failed with result 'dependency'.
sie 18 12:34:39 systemd[1]: dev-disk-by\x2dlabel-leowindows.device: Job dev-disk-by\x2dlabel-leowindows.device/start failed with result 'timeout'.
sie 18 12:34:49 systemd[1]: dupa.service: Unit entered failed state.
sie 18 12:36:19 systemd[1]: mnt-windows.mount: Job mnt-windows.mount/start failed with result 'dependency'.
sie 18 12:36:19 systemd[1]: mnt-windows.mount: Job mnt-windows.mount/start failed with result 'dependency'.
sie 18 12:36:19 systemd[1]: dev-disk-by\x2dlabel-leowindows.device: Job dev-disk-by\x2dlabel-leowindows.device/start failed with result 'timeout'.
sie 18 12:36:19 systemd[1]: mnt-DYSK_D.mount: Job mnt-DYSK_D.mount/start failed with result 'dependency'.
sie 18 12:36:19 systemd[1]: systemd-fsck@dev-disk-by\x2dlabel-DYSK_D.service: Job systemd-fsck@dev-disk-by\x2dlabel-DYSK_D.service/start failed with result 'dependency'.
sie 18 12:36:19 systemd[1]: dev-disk-by\x2dlabel-DYSK_D.device: Job dev-disk-by\x2dlabel-DYSK_D.device/start failed with result 'timeout'.
sie 18 12:36:49 systemd[1]: dupa.service: Unit entered failed state.
sie 18 12:37:49 systemd[1]: dupa.service: Unit entered failed state.
EOF
}
	sendmail() { echo "sendmail $@"; cat; }
fi

log_myname=$(basename $0)
log() { echo "$log_myname:" "$@"; }

# main #################################################

if [ $# -lt 1 ]; then usage; exit 1; fi
tmp=$(getopt -n "systemctl-failure-monitor" -o i:d -l ignore:no-duplicate -- "$@")
eval set -- "$tmp"
ignore="" noduplicate=false
while true; do
	case "$1" in
		-i | --ignore ) ignore+="$2"$'\n'; shift 2; ;;
		-d | --no-duplicate) noduplicate=true; shift; ;;
		-- ) shift; break ;;
		* ) echo "internal error $1" >&2; exit 1; ;;
	esac
done

MAILTO=$1
shift
if [ $# -ne 0 ]; then usage; echo "Additoinal arguments on the end" >&2; exit 1; fi;

listAlreadyFailed=""
log "mailing to $MAILTO"

journalctl -b 0 -t systemd -f --no-pager --no-hostname -n10 | \
sed -u -n '
/Unit entered failed state/ s/^.*: \(.*\): Unit entered failed state.$/s \1/p;
/failed with result/        s/^.*: \(.*\): .*$/j \1/p;
' | \
while read -r type what; do

	if echo "$ignore" | grep -x -q -x "$what"; then
		# what is in ignore list, just ignore
		continue;
	fi

	if $noduplicate && echo "$listAlreadyFailed" | grep -x -q "$type $what"; then
		log "$what entered failed state again."
		continue;
	fi

	listAlreadyFailed="$type $what"$'\n'
	log "$what entered failed state -> sending mail to $MAILTO."
	sendmail $MAILTO <<EOF
To: $MAILTO
Subject: $(hostname -f): systemd: Unit $what entered failed state.

Unit $what entered failed state on machine $(hostname -f)

- Additional information ----------------------------------------------------
+ systemctl status $what -l
$(systemctl status $what -l)
+ journalctl -n -0 -u $what -n100
$(journalctl -n -0 -u $what -n100)
-----------------------------------------------------------------------------

This email is generated automatically by $0 script.
Refer to your configuration for knowing the hell is going on.

Have a nice day,
$0 script.
EOF

done


