#!/bin/bash
set -euo pipefail

fail2ban_list_banned_ips() {
	fail2ban-client status |
		sed '/.*Jail list: */!d; s///; s/,/ /g' |
		xargs -n1 fail2ban-client status |
		awk -F: '
			/Status for the jail:/{j=gensub(/.*: */, "", "1", $0)}
			/Banned IP list:/{ list=$2; split(list, arr, " "); for (i in arr) { print j, arr[i] }}
		'
}

cmds=$(compgen -A function | sed '/^fail2ban_/!d; s///')

usage() {
	cat <<EOF
Usage: $(basename "$0") command

Commands:
$(<<<"$cmds" sed 's/^/\t/')

EOF
}

if
		(($#)) &&
		cmd=fail2ban_$1 &&
		shift &&
		declare -F | grep -qx "$cmd"
then
	"$cmd" "$@"
else
	usage
fi

