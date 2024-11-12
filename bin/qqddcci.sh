#!/bin/bash
# shellcheck disable=2145,2046,2086,2034,2207,2004
# file: qqddcci.sh
# Licensed under GPL-3.0
#
# based on http://www.chrisbot.com/uploads/1/3/8/4/13842915/ddcciv1r1.pdf
# based on VESA(TM) DDC/CI(TM) Standard
########################### variables config #################################
set -euo pipefail

DEBUG=${DEBUG:-false}
VERBOSE=${VERBOSE:-false}
QUIET=${QUIET:-false}

# Functions ######################################################################

usage() {
        local n
		n=$(basename "$0")
        cat <<EOF
Usage: 
	$n [options] -r VCP
	$n [options] -r VCP -w Value
	$n [options] -C
	$n [options] -t STRING

This shell script uses i2c-tools to control monitor via ddc/ci interface.

Modes options:
   -r VCP                 read VCP value
   -r VCP -w VALUE        write VALUE to VCP
   -C                     query capabilities string
   -t STRING              translate value to hex and description of VCP register number
Other options:
   -i I2CBUS              an integer or an I2C bus name (default: 5)
   -d                     turn debug messages on
   -q                     be silent
   -h                     print this text and quit

Examples:
   $n -i 5 -r 0x10
   $n -i 5 -r 0x8d -w 0x00
   $n -i 5 -t 0x10 -t 20
   $n -i 5 -t "Select Color Preset"

Version 0.0.2
Written by Kamil Cukrowski (C) 2017. 
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3..
EOF
}

debug() { if $DEBUG; then echo "DEBUG: ${FUNCNAME[1]}():" "$@"; fi; }
info()  { if ! $QUIET; then echo "$@"; fi; }
warn()  { echo "WARN : ${FUNCNAME[1]}():" "$@" >&2; }
error() { echo "ERROR: ${FUNCNAME[1]}():" "$@" >&2; }
fatal() { echo "FATAL: ${FUNCNAME[1]}():" "$@" >&2; exit 1; }

checkVarNotEmpty() {
	if [ -z "${!1:-}" ]; then
		error "Variable $1 is empty!"
		return 1
	fi
}
checkVarIsNumber() { 
	if [ "${!1:-}" -ne "${!1:-}" ]; then
		error "Variable $1=${!1:-} is not a number!"
		return 1;
	fi
}
calcCrc() {
	local xor=0x00
	for i in "$@"; do
		xor=$(printf "0x%02x" $((xor^i)))
	done
	printf "0x%02x" "$xor"

}
testCalcCrc() {
	echo "0x35 =? $(calcCrc "$(printf "0x%02x" "$((0x37<<1))")" 0x51 0x84 0x03 0x8d 0x00 0x00)"
	echo "0x34 =? $(calcCrc "$(printf "0x%02x" "$((0x37<<1))")" 0x51 0x84 0x03 0x8d 0x00 0x01)"
}

################# ddcci

## ddcci consts
ddcci_dest_addr=0x37
ddcci_write_src_addr=0x51
ddcci_read_src_addr=0x6e
ddcci_virtual_host_address=0x50
readonly ddcci_dest_addr ddcci_write_src_addr ddcci_read_src_addr ddcci_pre

## ddcci global response/result variable
declare -A ddcci_res

## ddcci private
_ddcci_addCrc() {
	echo "$@" "$(calcCrc "$(printf "0x%02x" $(($1<<1)))" $(shift; echo "$@") )"
}
_ddcci_write() {
	local len
	len=$(echo "$@" | wc -w)
	i2cset -y $I2CBUS \
		$(_ddcci_addCrc $ddcci_dest_addr $ddcci_write_src_addr $(printf "0x%02x" $((0x80|len))) "$@") s
}
_ddcci_read() {
	local str len
	# remove leading line | convert to stream of bytes | upper to lower | remove new lines
	str=$(
		i2cdump -y $I2CBUS $ddcci_dest_addr s \
		| tail -n +2 | cut -d' ' -f2-17 | tr '\n' ' ' \
		| tr ' ' $'\t' |  tr '[:upper:]' '[:lower:]' \
		| sed 's/\([[:xdigit:]][[:xdigit:]]\)/0x\1/g'
	) 
	# extract length from the message and strip the message to the length
	len=$(( ( $(echo "$str" | cut -f2) & (~0x80) ) + 3 ))
	debug "received msg with length=$(echo "$str" | cut -f2)|$(( $(echo "$str" | cut -f2) & (~0x80) ))|$len" >&2
	str=$(echo "$str" | cut -f-$len)
	# some sanity checks - checksum and read address
	if [ $(echo "$str" | cut -f1) != $ddcci_read_src_addr ]; then
		error "$(echo "$str" | cut -f1) != $ddcci_read_src_addr - ddcci_read_src_addr"
		return 1
	fi
	if ${DDCCI_CHKSUM:-true}; then
		local calcrc msgcrc
		calcrc=$(calcCrc $ddcci_virtual_host_address $(echo "$str" | cut -f-$((len-1)) ) )
		msgcrc=$(echo "$str" | cut -f$((len)))
		if [ $msgcrc != $calcrc ]; then
			error "$msgcrc != $calcrc - checksum error"
			return 1
		fi
	fi
	# return readed string
	echo "$str"
}

## ddcci public
ddcci_set_vcp() {
	# first argument - VCP opcode
	# second argument - value (between 0 to 4096)
	_ddcci_write 0x03 $(printf "0x%02x 0x%02x 0x%02x" $1 $(( ($2&0xff00)>>8 )) $(( $2&0x00ff )) )
	sleep 0.05
}

ddcci_get_vcp() {
	local str
	_ddcci_write 0x01 $(printf "0x%02x" "$1")
	sleep 0.05
	str=( $(_ddcci_read) )
	sleep 0.05
	if [ ${str[2]} != 0x02 ]; then
		error "${str[2]} != 0x02 == VCP Feature reply op code"
		return 1
	fi
	# results returned in "global" variable ddcci_resp
	local -g ddcci_res
	ddcci_res["resultcode"]=$(case $(( str[3] )) in
		0) echo "NoError" ;; 
		1) echo "Unsupported VCP Code" ;; 
	esac)
	ddcci_res["vcp"]=${str[4]}
	ddcci_res["vcp_type"]=$( case $(( str[5] )) in
		0) echo "Set parameter" ;; 
		1) echo "Momentary" ;; 
	esac)
	ddcci_res["max"]=$(( str[6]<<8 | str[7] ))
	ddcci_res["present"]=$(( str[8]<<8 | str[9] ))
}

ddcci_get_timing() {
	local str
	_ddcci_write 0x07
	sleep 0.05
	str=( $(_dddci_read) )
	echo "${str[@]}"
	sleep 0.05
}

ddcci_save_current_settings() {
	_ddcci_write 0x0C
	sleep 0.2
}

ddcci_capabilities() { 
	local str bs
	bs=$((20-6))
	for i in $(seq 0 $bs $((0x200))); do
		_ddcci_write 0xf3 $(printf "0x%02x 0x%02x" $((i>>8)) $((i&0xff)) )
		sleep 0.05
		# theres something wrong with i2c or i2cdump - i get only 20 valid bytes max
		str=$( DDCCI_CHKSUM=false _ddcci_read | cut -f6-$((5+bs)))
		echo -n "$str" | xxd -r | sed 's/)/)\n/g'
		if [ $(echo "$str" | wc -w) -ne $bs ]; then
			break;
		fi
		sleep 0.05
	done
	echo
}

ddcci_translate_arr="
	0x00	Degauss
	0x01	Degauss
	0x02	Secondary Degauss
	0x04	Reset Factory Defaults
	0x05	SAM: Reset Brightness and Contrast
	0x06	Reset Factory Geometry
	0x08	Reset Factory Default Color
	0x0a	Reset Factory Default Position
	0x0c	Reset Factory Default Size
	0x0e	SAM: Image Lock Coarse
	0x10	Brightness
	0x12	Contrast
	0x14	Select Color Preset
	0x16	Red Video Gain
	0x18	Green Video Gain
	0x1a	Blue Video Gain
	0x1c	Focus
	0x1e	SAM: Auto Size Center
	0x20	Horizontal Position
	0x22	Horizontal Size
	0x24	Horizontal Pincushion
	0x26	Horizontal Pincushion Balance
	0x28	Horizontal Misconvergence
	0x2a	Horizontal Linearity
	0x2c	Horizontal Linearity Balance
	0x30	Vertical Position
	0x32	Vertical Size
	0x34	Vertical Pincushion
	0x36	Vertical Pincushion Balance
	0x38	Vertical Misconvergence
	0x3a	Vertical Linearity
	0x3c	Vertical Linearity Balance
	0x3e	SAM: Image Lock Fine
	0x40	Parallelogram Distortion
	0x42	Trapezoidal Distortion
	0x44	Tilt (Rotation)
	0x46	Top Corner Distortion Control
	0x48	Top Corner Distortion Balance
	0x4a	Bottom Corner Distortion Control
	0x4c	Bottom Corner Distortion Balance
	0x50	Hue
	0x52	Saturation
	0x54	Color Curve Adjust
	0x56	Horizontal Moire
	0x58	Vertical Moire
	0x5a	Auto Size Center Enable/Disable
	0x5c	Landing Adjust
	0x5e	Input Level Select
	0x60	Input Source Select
	0x62	Audio Speaker Volume Adjust
	0x64	Audio Microphone Volume Adjust
	0x66	On Screen Display Enable/Disable
	0x68	Language Select
	0x6c	Red Video Black Level
	0x6e	Green Video Black Level
	0x70	Blue Video Black Level
	0x8d	Mute
	0xa2	Auto Size Center
	0xa4	Polarity Horizontal Synchronization
	0xa6	Polarity Vertical Synchronization
	0xa8	Synchronization Type
	0xaa	Screen Orientation
	0xac	Horizontal Frequency
	0xae	Vertical Frequency
	0xb0	Settings
	0xb6	b6 r/o
	0xc6	c6 r/o
	0xc8	c8 r/o
	0xc9	c9 r/o
	0xca	On Screen Display
	0xcc	SAM: On Screen Display Language
	0xd4	Stereo Mode
	0xd6	SAM: DPMS control (1 - on/4 - stby)
	0xdc	SAM: MagicBright (1 - text/2 - internet/3 - entertain/4 - custom)
	0xdf	VCP Version
	0xe0	SAM: Color preset (0 - normal/1 - warm/2 - cool)
	0xe1	SAM: Power control (0 - off/1 - on)
	0xe2	e2 r/w
	0xed	SAM: Red Video Black Level
	0xee	SAM: Green Video Black Level
	0xef	SAM: Blue Video Black Level
	0xf5	SAM: VCP Enable
"

ddcci_translate() {
	local tmp=$1
	case "$tmp" in
	[0-9]*)
		tmp=$(printf "0x%02x" "$1")
		tmp=$(cut -f2 <<<"$ddcci_translate_arr" | grep -n     "$tmp" | cut -d':' -f1 || true)
		;;
	*)
		tmp=$(cut -f3- <<<"$ddcci_translate_arr" | grep -n -x "$tmp" | cut -d':' -f1 || true)
		;;
	esac
	if [ -z "$tmp" ]; then
		warn "String \"$1\" is not found in database"
		return 1;
	fi
	if [ $(echo "$tmp" | wc -l) -gt 2 ]; then
		warn "String \"$1\" returned multiple answers!"
		return 1
	fi
	for tmp in $tmp; do
		cat -n <<<"$ddcci_translate_arr" | grep "^\ *${tmp}"$'\t' | cut -f3-
	done
}

ddcci_translate_to_desc() {
	local tmp
	tmp=$(ddcci_translate "$@")
	read -r _ tmp <<<"$tmp"
	echo "$tmp"
}

ddcci_translate_to_hex() {
	local tmp
	tmp=$(ddcci_translate "$@")
	read -r tmp _ <<<"$tmp"
	echo "$tmp"
}

############## eof ddcci

################################## main ############################

if $DEBUG; then
	trap '[ $? != 0 ] && error "$0:$LINENO: Last command returned $?. Exiting! Dumping stack: ${FUNCNAME[@]}"' EXIT
fi

# Parse Input

if (($# == 0)); then
	usage
	exit 1
fi

I2CBUS=5 # global variable, referenced by ddcci module
VAL="" VCP="" translate=() capabilities=false donesmth=false

if ! ARGS=$(getopt -n "ddcci.sh" -o ":i:Vdr:w:qvhCt:" -- "$@"); then
	usage; echo; fatal "Failed parsing options.";
fi
eval set -- $ARGS

while true; do
	case "$1" in
    -i) I2CBUS=$2; shift; ;;
    -d) DEBUG=true;  ;; 
    -r) VCP=$2; shift; ;;
    -w) VAL=$2; shift; ;;
    -q) QUIET=true; ;;
    -h) usage; exit 1; ;;
    -C) capabilities=true; ;;
	-t) translate+=( "$2" ); shift; ;;
    --) shift; break ;;
    *) break ;;
  	esac
  	shift;
done

if $DEBUG; then
  i2cset() {
    echo + i2cset "$@" >&2
    command i2cset "$@"
  }
  i2cdump() {
  	echo + i2cdump "$@" >&2
  	command i2cdump "$@" | tee >(head -n5 >&2; echo >&2) | (sleep 0.2; cat)
  }
fi

checkVarNotEmpty I2CBUS

# Main Work

if [ -n "$VCP" ]; then
	VCP=$(ddcci_translate_to_hex "$VCP")
	if [ -z "$VAL" ]; then
		info "Reading $(ddcci_translate_to_desc "$VCP")"
		ddcci_get_vcp "$VCP"
		declare -p ddcci_res | sed 's/^declare -A //'
	else
		VAL=$(printf "%u" "$VAL")
		if [ "$VAL" -lt 0 ] || [ "$VAL" -gt 4096 ]; then
			error "Value to write VAL=$VAL must be between <0,4096>"
			exit 1
		fi
		info "Setting $(ddcci_translate $VCP)=$VAL"
		ddcci_set_vcp "$VCP" "$VAL"
	fi
elif $capabilities; then
	ddcci_capabilities
elif [ -n "${translate+x}" ]; then
	info "Hex"$'\t'"Description"
	for t in "${translate[@]}"; do
		ddcci_translate "$t"
	done
else
	usage; echo; fatal "Got nothing to do";
fi

