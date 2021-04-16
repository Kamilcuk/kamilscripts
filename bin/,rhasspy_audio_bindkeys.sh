#!/bin/bash
set -euo pipefail

###############################################################################

# shellcheck source=/usr/lib/kamilscripts/bin/lib_lib.sh
. lib_lib.sh -q

###############################################################################

notify() {
	notify-send -u low -t 2000 -i forward rhasspy_bindkeys "$*"
}

snt_load_config() {
	if ! g_snt=$(awk -v NAME="$L_name" '
		function fatal(desc) {
			printf NAME ": ERROR in RHASSPY_SENTENCES on line "NR": `"$0"`: " desc "\n" > "/dev/stderr"
			exit 1
		}
		/^[[:space:]]*\[[^]]*\][[:space:]]*$/{
			v=$0
			gsub(/^[[:space:]]*\[/, "", v)
			gsub(/\][[:space:]]*$/, "", v)
			name=v
			if (length(name) == 0) fatal("Section name is empty: " name)
			if (name ~ "[[:space:]]") fatal("Section name has spaces")
		}
		/^[[:space:]]*#[[:space:]]*!/{
			#
			opt=$0
			gsub(/[[:space:]]*#[[:space:]]*![[:space:]]*/, "", opt)
			cmd=opt
			gsub(/[[:space:]].*/, "", opt)
			gsub(/^[^[:space:]]*[[:space:]]*/, "", cmd)
			#
			if (length(name) == 0) fatal("No section")
			print name
			if (length(opt) == 0) fatal("Opt is empty")
			print opt
			if (length(cmd) == 0) fatal("Cmd is empty")
			print cmd
			print ""
		}
		' <<<"$RHASSPY_SENTENCES"
	); then
		L_fatal "Could not parse RHASSPY_SENTENCES from $RHASSPY_BINDKEYS_CONFIGFILE"
	fi
}

snt_parser() {
	awk "${@:1:$#-1}" '
		BEGIN{ RS="\n\n"; FS="\n"; OFS="\n"; ORS="\n"; }
		{ name=$1; opt=$2; cmd=$3; }
		'"${*: -1}"
}

snt_list() {
	<<<"$g_snt" snt_parser '{print name}' | sort -u
}

snt_get() {
	<<<"$g_snt" snt_parser -v arg="$1" 'arg == name'
}

###############################################################################

json_extract_interesting() {
	jq '[ { "intent": .intent.intentName }, (.slots[] | { (.entity): .value.value }) ] | add'
}

json_to_opts() {
	json_extract_interesting |
	jq -r 'to_entries | .[] | "OPT_" + .key + "='\''" + .value + "'\''"'
}

###############################################################################

rhasspy_publish() {
	mosquitto_pub -h "$RHASSPY_MQTT_HOST" -p "$RHASSPY_MQTT_PORT" "$@"
}

rhasspy_subscribe() {
	stdbuf -oL mosquitto_sub -h "$RHASSPY_MQTT_HOST" -p "$RHASSPY_MQTT_PORT" "$@"
}

rhasspy_say() {
	local arg
	arg=$(jq -n --arg a "$*" --arg site "$RHASSPY_SITE" '{"text": $a, "lang": "en-US", "siteId": $site}')
	rhasspy_publish -t hermes/tts/say -m "$arg"
}

rhasspy_retrain() {
	curl -X POST "${RHASSPY_HTTP_URL}/api/train" -H  "accept: text/plain" &&
	echo
}

###############################################################################

audio_mute() {
	if "$muted"; then return; fi
	muted=true
	L_log "audio mute"
	pactl set-sink-mute @DEFAULT_SINK@ 1
}

audio_unmute() {
	if ! "$muted"; then return; fi
	muted=false
	L_log "audio unmute"
	pactl set-sink-mute @DEFAULT_SINK@ 0
}

job_silence_audio_when_detecting_words() {
	L_name+=": audiosilencer"
	trap 'jobs_kill ; L_log quit' EXIT

	L_log "Starting..."
	rhasspy_subscribe -v -t hermes/asr/'#' | { 
		detecting=false
		muted=true
		while 
			IFS=' ' read -r topic payload &&
			siteid=$(jq -r .siteId <<<"$payload") &&
			[[ "$siteid" == "$RHASSPY_SITE" ]]
		do
			case "$topic" in
			(hermes/asr/startListening)
				audio_mute
				;;
			(*)
				audio_unmute
				;;
			esac
			#L_log "Read $line"
		done
	}

	exit
}

###############################################################################

job_notify_about_wake_word() {
	rhasspy_subscribe -t hermes/hotword/+/detected |
		while IFS= read -r line; do
			notify "Wake word detected"
		done
}

###############################################################################

intent_run() {
	intent="$1"
	line="$2"

	tmp=$(snt_get "$intent")
	if [[ -z "$tmp" ]]; then
		L_log "Not handled intent: $intent $line"
		return 1
	fi

	local opts
	opts=$(<<<"$line" json_to_opts | paste -sd' ') ||:
	L_log "$line"
	L_log "Handling $intent with $opts"

	while
		IFS= read -u10 -r name &&
		IFS= read -u10 -r opt &&
		IFS= read -u10 -r cmd
	do
		case "$opt" in
		say) 
			(
				set +ueo pipefail
				set +a
				cd
				tmp=$(envsubst <<<"$cmd")
				rhasspy_say "$tmp"
			) ||:
			;;
		run)
			(
				set +ueo pipefail
				set +a
				cd
				notify "$cmd"
				eval "$cmd" <<<"$line" <&10-
			) ||:
			;;
		esac
	done 10<<<"$tmp"
}

job_handle_intents() {
	L_name+=": intenthandler"
	trap 'jobs_kill ; L_log quit' EXIT
	local intents
	intents=$(snt_list | paste -sd' ')
	L_log "Watching intents: $intents"
	L_run rhasspy_subscribe -t hermes/intent/'#' | {
		while
			IFS= read -u 11 -r line &&
			intent=$(jq -r .intent.intentName <<<"$line" | sed 's/[[:space:]]/_/g')
		do
			( intent_run "$intent" "$line" ) ||:
		done
	} 11<&0 0<&-
}

###############################################################################

job_retrain() {
	L_name+=": retrainer"
	trap 'jobs_kill ; L_log quit' EXIT
	L_log "Retraining Rhasspy..."
	if ! cat <<<"$RHASSPY_SENTENCES" >"$RHASSPY_SENTENCES_FILE"; then
		L_fatal "Could not write into $RHASSPY_SENTENCES_FILE"
	fi
	if ! rhasspy_retrain; then
		L_fatal "Could not retrain Rhasspy"
	fi
}

###############################################################################

jobs_kill() {
	local IFS
	IFS=$' \t\n'
	for j in $(jobs | awk '{gsub("[^0-9]","",$1);print $1}'); do kill %$j; done
}

load_user_config() {
	# Default configuration values
	RHASSPY_SENTENCES=""
	RHASSPY_SITE=$HOSTNAME
	RHASSPY_HTTP_URL="http://localhost:12101"
	RHASSPY_SENTENCES_FILE="$HOME/.config/rhasspy/profiles/en/intents/rhasspy_bindkeys_sentences.ini"
	RHASSPY_MQTT_PORT=12183
	RHASSPY_MQTT_HOST=localhost
	# Load user config
	if ! . "$RHASSPY_BINDKEYS_CONFIGFILE"; then
		L_fatal "Sourcing $RHASSPY_BINDKEYS_CONFIGFILE failed"
	fi
	if [[ -z "$RHASSPY_SENTENCES" ]]; then
		L_fatal "SENTENCES is not set in $RHASSPY_BINDKEYS_CONFIGFILE"
	fi
	# Load snt lib
	snt_load_config <<<"$RHASSPY_SENTENCES"
}

jobs_run() {
	trap 'jobs_kill' EXIT
	jobs_kill
	wait
	load_user_config
	L_log "Running jobs..."
	if [[ "${1:-}" != "first" ]]; then
		# Do not retrain on first start
		job_retrain &
	fi
	job_silence_audio_when_detecting_words &
	job_handle_intents &
}

###############################################################################

C_say() { rhasspy_say "$@"; }
C_pub() { rhasspy_publish "$@"; }
C_sub() { rhasspy_subscribe "$@"; }
C_run() { trap 'jobs_kill' EXIT; jobs_run "$@"; wait; }
C_watcher() {
	trap 'jobs_kill ; kill 0' EXIT
	L_log "Starting monitoring of $0 and $RHASSPY_BINDKEYS_CONFIGFILE ..."
	#
	inotifywait -m -q -e close_write,moved_to --no-newline --format "%w%f%0" \
			"$(dirname "$0")" "$(dirname "$RHASSPY_BINDKEYS_CONFIGFILE")" | {
		# Run initial run.
		jobs_run first
		while IFS= read -r -d '' file; do
			# L_log "$file"
			if [[ "$file" = "$0" ]]; then
				kill -SIGUSR1 $$
			elif [[ "$file" = "$RHASSPY_BINDKEYS_CONFIGFILE" ]]; then
				L_log "config refresh event: $RHASSPY_BINDKEYS_CONFIGFILE"
				jobs_run
			fi 
		done 
	} &
	#
	restart() {
		L_log "Script was modified, restarting ourselves..."
		jobs_kill
		exec "$0" "$@" watcher
	}
	trap restart SIGUSR1
	#
	wait
}

###############################################################################

usage_() {
	echo "$@"
	exit
}

###############################################################################

exec 0<&-
g_verbose=0
RHASSPY_BINDKEYS_CONFIGFILE="${RHASSPY_BINDKEYS_CONFIGFILE:-"$HOME/.config/rhasspy/rhasspy_bindkeys.conf.sh"}"
args=$(getopt -n "$L_name" -o +hvc: -l help,verbose,config: -- "$@")
eval set -- "$args"
while (($#)); do
	case "$1" in
	-h|--help) usage; ;;
	-v|--verbose) ((g_verbose++))||:; ;;
	-c|--config) RHASSPY_BINDKEYS_CONFIGFILE="$2"; shift; ;;
	--) shift; break; ;;
	*)  L_fatal "Error parsign arguments"; ;;
	esac
done

load_user_config

. ,lib_lib C_ "$@"

	









