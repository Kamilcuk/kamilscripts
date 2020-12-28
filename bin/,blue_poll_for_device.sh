#!/bin/bash
set -euo pipefail

n=blue_poll_for_device.sh

usage() {
	cat <<EOF
Usage: $n [options] [device]

Uses bluetoothctl tool to scan if a device is available.
Then connects to the device and wait until the device is disconnected.
Then the process repeats.
The default device is 00:02:00:00:06:29

Options:
  -h --help  Print this help and exit.
  -d --debuglbuetoothctl  Debug all data to/from bluetoothctl.
  -q --quiet  Print nothing

Written by Kamil Cukrowski.
Licensed jointly under Beerware and MIT license.
EOF
}

fatal() {
	echo "ERROR:" "$@" >&2
	exit 2
}

log() {
	if [ -z "${quiet:-}" ]; then
		printf "$*\n"
	fi
}

# main ############################################################

args=$(getopt -n "$n" -o hdq -l help,debugbluetoothctl,quiet -- "$@")
eval set -- "$args"
while (($#)); do
	case "$1" in
	-h|--help) usage; exit; ;;
	-d|--debugbluetoothctl) debugbluetoothctl=true; ;;
	-q|--quiet) quiet=true; ;;
	--) shift; break; ;;
	esac
	shift
done

if ! hash bluetoothctl 2>/dev/null >/dev/null; then
	fatal "bluetoothctl not found"
fi
if ! type coproc 2>/dev/null | grep -q keyword >/dev/null; then
	fatal "coproc builtin not found"
fi
if (($# > 1)); then
	fatal "Too many arguments specified - supporting multiple is simple modification but is TODO"
fi
d=${1:-00:02:00:00:06:29}


# setup exit trap to cleanup the bluetoothctl child
exit_trap() {
	if [ -z "$B_PID" ]; then
		return
	fi
	kill $B_PID
	wait $B_PID
}
trap 'exit_trap' EXIT

# run bluetoothctl process
if [ -z "${debugbluetoothctl:-}" ]; then
	coproc B { bluetoothctl; }
else
	coproc B {
		tee >(cat -v | sed 's/^/IN : /' >&2) |
		bluetoothctl |
		tee >(cat -v | sed 's/^/OUT: /' >&2);
	}
fi
out=${B[1]}
in=${B[0]}

# some default init
printf "%s\n" "agent on" "default-agent" "power on" >&$out

while :; do
	# scan for device and wait
	log "Scanning devices, waiting for $d..."
	echo "scan on" >&$out
	grep -q -m1 --line-buffered "Device $d" <&$in
	echo "scan off" >&$out
	log "Device $d discovered, connecting..."

	# connect the device
	# connecting to already connected device just prints "Connection successful" so it's fine
	echo "connect $d" >&$out

	# wait for connection
	ret=0
	tmp=$(timeout 10 grep -m1 --line-buffered "Connection successful\|Failed to connect: " <&$in) || ret=$?
	if ! grep -q "Connection successful" <<<"$tmp"; then
		log "Connecting to $d failed."
		continue
	fi
	log "Connected to $d device."

	# set pulseaudio defualt sink to combined
	#sleep 1
	#pactl set-default-sink combined || :

	# Wait until device is connected
	grep -q -m1 "Device $d Connected: no" <&$in
	log "Device $d disconnected."
done
		

