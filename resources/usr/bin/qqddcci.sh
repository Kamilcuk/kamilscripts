#!/bin/bash -e
# file: qqddcci.sh
# licensed under MIT+Beerware Kamil Cukrowski 
#
# based on http://www.chrisbot.com/uploads/1/3/8/4/13842915/ddcciv1r1.pdf
# based on VESA(TM) DDC/CI(TM) Standard
########################### variables config #################################

DEBUG=${DEBUG:-false}
VERBOSE=${VERBOSE:-false}
CHKSUM=${CKSUM:-true}
$DEBUG && set -x

############################ functions ###########################


checkNotEmpty() {
	if [ -z "$(eval echo \${$1:-})" ]; then
		perror "Variable $1 is empty!"
		return 1
	fi
}
checkNumber() { 
	if [ "$(eval echo \${$1:-})" -ne "$(eval echo \${$1:-})" ]; then
		perror "Variable $1=$(eval echo \$$1) is not a number!"
		return 1;
	fi
}
calcCrc() {
	local xor=0x00
	for i in "$@"; do
		xor=$(printf "0x%02x" $((xor^i)))
	done
	printf "0x%02x" $xor

}
testCalcCrc() {
	echo "0x35 =? $(calcCrc $(printf "0x%02x" $((0x37<<1))) 0x51 0x84 0x03 0x8d 0x00 0x00)"
	echo "0x34 =? $(calcCrc $(printf "0x%02x" $((0x37<<1))) 0x51 0x84 0x03 0x8d 0x00 0x01)"
}

perror() { echo "${FUNCNAME[1]}: ERROR: $@" >&2; }

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
	echo "$@"" $(calcCrc $(printf "0x%02x" $(($1<<1))) $(shift; echo "$@") )"
}
_ddcci_write() {
	local len
	len=$(echo "$@" | wc -w)
	i2cset -y $I2CBUS \
		$(_ddcci_addCrc $ddcci_dest_addr $ddcci_write_src_addr $(printf "0x%02x" $((0x80|len))) "$@") i
}
_ddcci_read() {
	local str len
	# remove leading line | convert to stream of bytes | upper to lower | remove new lines
	str=$(
		i2cdump -y $I2CBUS $ddcci_dest_addr i | \
	 		tail -n +2 | cut -d' ' -f2-17 | tr '\n' ' ' | \
			sed 's/\([[:xdigit:]][[:xdigit:]]\)/0x\1/g' | tr '[:upper:]' '[:lower:]'
	)
	# extract length from the message and strip the message to the length
	len=$(( ( $(echo "$str" | cut -d' ' -f2) & (~0x80) ) + 3 ))
	$VERBOSE && echo "received msg with length=$(echo "$str" | cut -d' ' -f2)|$(( $(echo "$str" | cut -d' ' -f2) & (~0x80) ))|$len" >&2
	str=$(echo "$str" | cut -d' ' -f-$len)
	# some sanity checks - checksum and read address
	if [ $(echo ${str} | cut -d' ' -f1) != $ddcci_read_src_addr ]; then
		perror "$(echo ${str} | cut -d' ' -f1) != $ddcci_read_src_addr - ddcci_read_src_addr"
		return 1
	fi
	if $CHKSUM; then
		local calcrc msgcrc
		calcrc=$(calcCrc $ddcci_virtual_host_address $(echo "$str" | cut -d' ' -f-$((len-1)) ) )
		msgcrc=$(echo ${str} | cut -d' ' -f$((len)))
		if [ $msgcrc != $calcrc ]; then
			perror "$msgcrc != $calcrc - checksum error"
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
	_ddcci_write 0x01 $(printf "0x%02x" $1)
	sleep 0.05
	str=( $(_ddcci_read) )
	sleep 0.05
	if [ ${str[2]} != 0x02 ]; then
		perror "${str[2]} != 0x02 == VCP Feature reply op code"
		return 1
	fi
	# results returned in "global" variable ddcii_resp
	ddcci_res["resultcode"]=$(case $(( ${str[3]} )) in 0) echo "NoError" ;; 1) echo "Unsupported VCP Code" ;; esac)
	ddcci_res["vcp"]=${str[4]}
	ddcci_res["vcp_type"]=$( case $(( ${str[5]} )) in 0) echo "Set parameter" ;; 1) echo "Momentary" ;; esac)
	ddcci_res["max"]=$(( ${str[6]}<<8 | ${str[7]} ))
	ddcci_res["present"]=$(( ${str[8]}<<8 | ${str[9]} ))
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
		str=$( CHKSUM=false _ddcci_read | cut -d' ' -f6-$((5+bs)))
		echo -n "$str" | xxd -r | sed 's/)/)\n/g'
		if [ $(echo "$str" | wc -w) -ne $bs ]; then
			break;
		fi
		sleep 0.05
	done
	echo
}
ddcci_translate() {
	case "$(printf "0x%02x" "$1")" in
	0x00) echo "Degauss"; ;;
	0x01) echo "Degauss"; ;;
	0x02) echo "Secondary Degauss"; ;;
	0x04) echo "Reset Factory Defaults"; ;;
	0x05) echo "SAM: Reset Brightness and Contrast"; ;;
	0x06) echo "Reset Factory Geometry"; ;;
	0x08) echo "Reset Factory Default Color"; ;;
	0x0a) echo "Reset Factory Default Position"; ;;
	0x0c) echo "Reset Factory Default Size"; ;;
	0x0e) echo "SAM: Image Lock Coarse"; ;;
	0x10) echo "Brightness"; ;;
	0x12) echo "Contrast"; ;;
	0x14) echo "Select Color Preset"; ;;
	0x16) echo "Red Video Gain"; ;;
	0x18) echo "Green Video Gain"; ;;
	0x1a) echo "Blue Video Gain"; ;;
	0x1c) echo "Focus"; ;;
	0x1e) echo "SAM: Auto Size Center"; ;;
	0x20) echo "Horizontal Position"; ;;
	0x22) echo "Horizontal Size"; ;;
	0x24) echo "Horizontal Pincushion"; ;;
	0x26) echo "Horizontal Pincushion Balance"; ;;
	0x28) echo "Horizontal Misconvergence"; ;;
	0x2a) echo "Horizontal Linearity"; ;;
	0x2c) echo "Horizontal Linearity Balance"; ;;
	0x30) echo "Vertical Position"; ;;
	0x32) echo "Vertical Size"; ;;
	0x34) echo "Vertical Pincushion"; ;;
	0x36) echo "Vertical Pincushion Balance"; ;;
	0x38) echo "Vertical Misconvergence"; ;;
	0x3a) echo "Vertical Linearity"; ;;
	0x3c) echo "Vertical Linearity Balance"; ;;
	0x3e) echo "SAM: Image Lock Fine"; ;;
	0x40) echo "Parallelogram Distortion"; ;;
	0x42) echo "Trapezoidal Distortion"; ;;
	0x44) echo "Tilt (Rotation)"; ;;
	0x46) echo "Top Corner Distortion Control"; ;;
	0x48) echo "Top Corner Distortion Balance"; ;;
	0x4a) echo "Bottom Corner Distortion Control"; ;;
	0x4c) echo "Bottom Corner Distortion Balance"; ;;
	0x50) echo "Hue"; ;;
	0x52) echo "Saturation"; ;;
	0x54) echo "Color Curve Adjust"; ;;
	0x56) echo "Horizontal Moire"; ;;
	0x58) echo "Vertical Moire"; ;;
	0x5a) echo "Auto Size Center Enable/Disable"; ;;
	0x5c) echo "Landing Adjust"; ;;
	0x5e) echo "Input Level Select"; ;;
	0x60) echo "Input Source Select"; ;;
	0x62) echo "Audio Speaker Volume Adjust"; ;;
	0x64) echo "Audio Microphone Volume Adjust"; ;;
	0x66) echo "On Screen Display Enable/Disable"; ;;
	0x68) echo "Language Select"; ;;
	0x6c) echo "Red Video Black Level"; ;;
	0x6e) echo "Green Video Black Level"; ;;
	0x70) echo "Blue Video Black Level"; ;;
	0x8d) echo "Mute"; ;;
	0xa2) echo "Auto Size Center"; ;;
	0xa4) echo "Polarity Horizontal Synchronization"; ;;
	0xa6) echo "Polarity Vertical Synchronization"; ;;
	0xa8) echo "Synchronization Type"; ;;
	0xaa) echo "Screen Orientation"; ;;
	0xac) echo "Horizontal Frequency"; ;;
	0xae) echo "Vertical Frequency"; ;;
	0xb0) echo "Settings"; ;;
	0xb6) echo "b6 r/o"; ;;
	0xc6) echo "c6 r/o"; ;;
	0xc8) echo "c8 r/o"; ;;
	0xc9) echo "c9 r/o"; ;;
	0xca) echo "On Screen Display"; ;;
	0xcc) echo "SAM: On Screen Display Language"; ;;
	0xd4) echo "Stereo Mode"; ;;
	0xd6) echo "SAM: DPMS control (1 - on/4 - stby)"; ;;
	0xdc) echo "SAM: MagicBright (1 - text/2 - internet/3 - entertain/4 - custom)"; ;;
	0xdf) echo "VCP Version"; ;;
	0xe0) echo "SAM: Color preset (0 - normal/1 - warm/2 - cool)"; ;;
	0xe1) echo "SAM: Power control (0 - off/1 - on)"; ;;
	0xe2) echo "e2 r/w"; ;;
	0xed) echo "SAM: Red Video Black Level"; ;;
	0xee) echo "SAM: Green Video Black Level"; ;;
	0xef) echo "SAM: Blue Video Black Level"; ;;
	0xf5) echo "SAM: VCP Enable"; ;;
	*)    echo "Unknown($1)"; ;;
esac
}
############## eof ddcci

################################## main ############################

trap '[ $? != 0 ] && perror "$0:$LINENO: Last command returned $?. Exiting! Dumping stack: ${FUNCNAME[@]}"' EXIT

usage() {
        local n=$(basename $0)
        cat <<EOF
Usage: $n [-hvq] [-i I2CBUS] [-r VCP [-w value]] [-C]

This shell script uses i2c-tools to control monitor via ddc/ci interface.

   -i I2CBUS              an integer or an I2C bus name (default: 5)
   -V                     verbose mode
   -d                     debug mode (set -x)
   -r VCP                 query vcp values
   -w VAL                 value to write to CTRL
   -q                     be silent
   -h                     print this text and quit
   -v                     same as -h
   -C                     query capabilities

Examples:
   $n -i 5 -r 0x01
   $n -i 5 -r 0x8d -w 0x00

Version 0.0.1
Written by Kamil Cukrowski (c) 2017
Under MIT+Beerware License
EOF
}

[ $# -eq 0 ] && { usage; exit 1; } || true

I2CBUS=5 # global variable, referenced by ddcci module
VAl=
VCP=
silent=false
capabilities=false
donesmth=false
while getopts ":i:Vdr:w:qvhC" opt; do
  case $opt in
    i) I2CBUS=$OPTARG; ;;
    V) VERBOSE=true; ;;
    d) DEBUG=true; set -x; ;; 
    r) VCP=$OPTARG; ;;
    w) VAL=$OPTARG; ;;
    q) silent=true; ;;
    v|h) usage; exit 1; ;;
    C) capabilities=true; ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage; exit 1; ;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage; exit 1;  ;;
  esac
done

if $VERBOSE; then
  i2cset() {
    (set -x; command i2cset "$@")
  }
  i2cdump() {
    (set -x; command i2cdump "$@") | tee >(head -n5 >&2; echo >&2) | (sleep 0.2; cat)
  }
fi

checkNotEmpty I2CBUS
if [ -n "$VCP" ]; then
	VCP=$(printf "%u" "$VCP")
	if [ -z "$VAL" ]; then
		if ! $silent; then
			echo "Reading $(ddcci_translate $VCP)"
		fi
		ddcci_get_vcp $VCP
		declare -p ddcci_res | sed 's/^declare -A //'
	else
		VAL=$(printf "%u" "$VAL")
		if [ "$VAL" -lt 0  -o "$VAL" -gt 4096 ]; then
			perror "Value to write VAL=$VAL must be between <0,4096>"
			exit 1
		fi
		ddcci_set_vcp $VCP $VAL
		if ! $silent; then
			echo "Setting $(ddcci_translate $VCP)=$VAL"
		fi
	fi
	donesmth=true
fi

if $capabilities; then
	ddcci_capabilities
	donesmth=true
fi

if ! $donesmth; then
	perror "Nothing to do?"
	usage
	exit 1
fi

