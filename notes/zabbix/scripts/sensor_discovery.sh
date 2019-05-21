#!/bin/bash
set -euo pipefail

outl() {
	printf "\t%.0s" $(seq $1)
	shift
	printf "%s\n" "$@"
}
p() {
	printf "%s\n" "$@";
}

addout() {
	if [ -n "$str" ]; then
		str=$(p "$str" | sed 's/,$//')
		if ! $disable; then 
			printf "{%s}," "$(p "$str" | sed 's/,$//')"
		fi
		disable=false
	fi
}

str=
chip=
once=true
disable=false
printf "%s" '{"data":['
sensors -u \
| while read l; do 
	case "$l" in 
	'') str=; ;;
	Adapter:*)
		adapter=$(p "$l" | cut -d' ' -f2)
		;;
	*_*:\ *)
		if $once; then 
			once=false
			# ${p}_${k}: ${v}
			p=$(p "$l" | cut -d_ -f1)
			k=$(p "$l" | cut -d_ -f2 | cut -d: -f1)
			v=$(p "$l" | cut -d' ' -f2)
			key=$p
			case "$p" in
			intrusion*) disable=true; ;; # can't get a good key
			in*) unit=V; ;;
			cpu*) unit=V; key="${p}_${k}"; disable=true; ;; # can't get a valid key for sensor[...,...]
			temp*) unit=C; ;;
			fan*) unit=RPM; ;;
			*) unit=; ;;
			esac
			str+="\"{#KEY}\":\"$key\",\"{#UNIT}\":\"$unit\","

			addout
		fi
		#str+="\"{#SENS_$t}\":$v,"
		;;
	*:)
		once=true
		name=$(p "$l" | cut -d: -f1)
		str="\"{#CHIP}\":\"$chip\",\"{#NAME}\":\"$name\",\"{#ADAPTER}\":\"${adapter}\","
		;;
	*-*)
		once=true
		chip=$l
		str=
		;;
	esac
done | head -c-1
printf "%s" "]}"


