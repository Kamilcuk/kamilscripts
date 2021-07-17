#!/bin/bash
set -euo pipefail

. ,lib_lib -q

usage() {
	cat <<EOF
Usage: $L_NAME [options] [device]

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

bl_run() {
	if ! hash bluetoothctl 2>/dev/null >/dev/null; then
		fatal "bluetoothctl not found"
	fi
	if ! type coproc 2>/dev/null | grep -q keyword >/dev/null; then
		fatal "coproc builtin not found"
	fi

	# setup exit trap to cleanup the bluetoothctl child
	exit_trap() {
		if [ -z "$bluectl_PID" ]; then
			return
		fi
		kill "$bluectl_PID"
		wait "$bluectl_PID"
	}
	trap 'exit_trap' EXIT
	# run bluetoothctl process
	if [ -z "${debugbluetoothctl:-}" ]; then
		coproc bluectl { bluetoothctl; }
	else
		coproc bluectl {
			tee >(cat -v | sed 's/^/IN : /' >&2) |
			bluetoothctl |
			tee >(cat -v | sed 's/^/OUT: /' >&2);
		}
	fi

	bl_pid="$bluectl_PID"
	bl_out=${bluectl[1]}
	bl_in=${bluectl[0]}
}

bl_block_until_line() {
	local tout tend now
	printf -v now "%(%s)T"
	tend=${2:+ (now * 1000) + ${2:-} }
	while
		set -x
		printf -v now "%(%s)T" &&
		tout=$(( tend > now ? tend - now + 1 : 1 )) &&
		printf -v tout "$d.%03d" "$((tout/1000))" "$((tout%1000))"
		IFS= read -u "$bl_in" ${2:+-t "$tout"} -r bl_line
	do
		# Remove color codes.
		bl_line="${bl_line//$'\E['+([^m])m}"
		# Remove CR.
		bl_line="${bl_line//$'\r'}"
		if [[ "$bl_line" =~ $1 ]]; then
			return 0
		fi
	done
	return 1
}

bl_echo() {
	L_debug "bl_echo $*"
	printf '%s\n' "$*" >&"$bl_out"
}

C_poll_for_device() {
	bl_run

	d=${1:-00:02:00:00:06:29}

	# some default init
	bl_echo "agent on"
	bl_echo "default-agent"
	bl_echo "power on"

	while :; do
		# scan for device and wait
		L_log "Scanning devices, waiting for $d..."
		bl_echo "scan on"
		bl_block_until_line "\[CHG\] Device $d RSSI:"
		bl_echo "scan off"
		L_log "Device $d discovered, connecting..."

		# connect the device
		# connecting to already connected device just prints "Connection successful" so it's fine
		bl_echo "connect $d"

		# wait for connection
		if ! bl_block_until_line 'Connection successful|Failed to connect: ' 10000 ||
				[[ ! "$bl_line" =~ "Connection successful" ]]; then
			L_log "Connecting to $d failed: $bl_line"
			continue
		fi
		L_log "Connected to $d device."

		# set pulseaudio defualt sink to combined
		#sleep 1
		#pactl set-default-sink combined || :

		# Wait until device is connected
		bl_block_until_line "Device $d connected: no"
		L_log "Device $d disconnected."
	done	
}


# main ############################################################

L_argparse prefix=a_ description="
Uses bluetoothctl tool to scan if a device is available.
Then connects to the device and wait until the device is disconnected.
Then the process repeats.
The default device is 00:02:00:00:06:29
" -- \
	-d --debuglbuetoothctl nargs=0 type=boolint help='Debug all data to/from bluetoothctl' -- \
	-q --quiet nargs=0 type=boolint help='Be quiet' -- \
	args nargs=+ -- \
	-- "$@"
if ((a_quiet)); then
	L_log_set_level L_LOG_WARNING
fi

. ,lib_lib C_ "${a_args[@]}"

