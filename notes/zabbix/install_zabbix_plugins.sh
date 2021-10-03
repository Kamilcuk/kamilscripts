#!/bin/bash
set -xeuo pipefail 

usage() {
	cat <<EOF
Usage: $0 <configuration destination>

Written by Kamil Cukrowski
EOF
}


if [ $# -eq 0 ] || [  -e "${1:-}" ]; then usage; exit 1; fi;
dst=$1

if [ ! -e "$dst/zabbix_agentd.conf" ]; then
	echo "ERROR: no such file as $dst/zabbix_agentd.conf"
	exit 1
fi

mkdir -p "$dst/scripts" "$dst/zabbix_agentd.d"
cp -v scripts/* "$dst/scripts/"
cp -v zabbix_agentd.d/* "$dst/zabbix_agentd.d/"
cp -v sudoers.d/* /etc/sudoers.d/
line='Include=/etc/zabbix/zabbix_agentd.d/*.conf'
file=/etc/zabbix_agentd.conf
if ! grep -q "$line" "$file"; then
	echo "Adding confguration file"
	echo "$line" >> "$file"
fi

	





