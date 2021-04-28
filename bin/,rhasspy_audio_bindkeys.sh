#!/bin/bash
set -euo pipefail

###############################################################################

# shellcheck source=/usr/lib/kamilscripts/bin/lib_lib.sh
. lib_lib.sh -q

###############################################################################

L_fatal() {
	notify "$@"
	L_error "$@"
	exit 1
}

notify() { notify-send -u low -t 4000 -i forward rhasspy_bindkeys "$@"; }
say() { rhasspy_say "$@"; }
notifysay() { notify "$@"; rhasspy_say "$@"; }
saynotify() { notifysay "$@"; }

load_user_config() {
	# Default configuration values
	RHASSPY_SITE=$HOSTNAME
	RHASSPY_HTTP_URL="http://localhost:12101"
	RHASSPY_MQTT_PORT=12183
	RHASSPY_MQTT_HOST=localhost
	# Load user config
	local tmp
	tmp=$(sed -n 's/^[[:space:]]*#[[:space:]]\+//p' "$RHASSPY_BINDKEYS_CONFIGFILE")
	L_log "Loading config file: $RHASSPY_BINDKEYS_CONFIGFILE"
	if ! eval "$tmp"; then
		L_fatal "Sourcing $RHASSPY_BINDKEYS_CONFIGFILE failed"
	fi
	# Load snt lib
	snt_load_config "$RHASSPY_BINDKEYS_CONFIGFILE"
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
			name = v
			if (length(name) == 0) fatal("Section name is empty: " name)
			if (name ~ "[[:space:]]") fatal("Section name has spaces: " name)
			if (name in names) fatal("Section defined twice: " name)
			names[name]
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
		' "$1"
	); then
		L_fatal "Could not parse from $1"
	fi
}

snt_parser() {
	<<<"$g_snt" awk "${@:1:$#-1}" '
		BEGIN{ RS="\n\n"; FS="\n"; OFS="\n"; ORS="\n"; }
		{ name=$1; opt=$2; cmd=$3; }
		'"${*: -1}"
}

snt_list() {
	snt_parser '{print name}' | sort -u
}

snt_get() {
	snt_parser -v arg="$1" 'arg == name'
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
	L_run stdbuf -oL mosquitto_sub -h "$RHASSPY_MQTT_HOST" -p "$RHASSPY_MQTT_PORT" "$@"
}

rhasspy_say() {
	local arg
	arg=$(jq -c -n --arg a "$*" --arg site "$RHASSPY_SITE" '{"text": $a, "siteId": $site}')
	rhasspy_publish -t hermes/tts/say -m "$arg"
}

rhasspy_wait_for_say_finished() {
	local timeout
	timeout="${1:-}"
	${timeout:+timeout $timeout} mosquitto_sub -h "$RHASSPY_MQTT_HOST" -p "$RHASSPY_MQTT_PORT" -t hermes/tts/sayFinished -C 1 ||:
}

rhasspy_curl() {
	# shellcheck disable=SC2145
	curl "${RHASSPY_HTTP_URL}/$@" &&
	echo
}

rhasspy_retrain() {
	rhasspy_curl /api/train -X POST -H "accept: text/plain"
}

rhasspy_listen_for_command() {
	rhasspy_curl /api/listen-for-command -X POST -H  "accept: */*"
}

###############################################################################

audio_muted=true
audio_mute() {
	if "$audio_muted"; then return; fi
	audio_muted=true
	L_log "audio mute"
	pactl set-sink-mute @DEFAULT_SINK@ 1
}

audio_unmute() {
	if ! "$audio_muted"; then return; fi
	audio_muted=false
	L_log "audio unmute"
	pactl set-sink-mute @DEFAULT_SINK@ 0
}

###############################################################################

job_silence_audio_when_detecting_words() {
	L_name+=": audiosilencer"
	trap 'jobs_kill ; L_log quit' EXIT

	L_log "Starting..."
	rhasspy_subscribe -v -t hermes/asr/'#' | { 
		detecting=false
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

r_intent_confirmyes() {
	local IFS=$' \t'
	read -r cmd <<<"$1"
	r_c_yes="yes"
	r_c_todo+=("$cmd")
}

r_intent_confirm_check() {
	if [[ "$OPT_intent" == "${r_c_yes:-}" ]]; then
		for i in "${r_c_todo[@]}"; do
			r_intent_exe "$i"
		done
	fi
	r_c_todo=
	r_c_yes=
}

r_intent_confirm_post() {
	if [[ -n "${r_c_yes:-}" ]]; then
		rhasspy_listen_for_command
	fi
}

r_intent_exe() {
	set -- eval "$*"
	set +ueo pipefail
	set +a
	pushd "$HOME" >/dev/null
	set -x
	{ "$@"; } <<<"$OPT_line"
	set +x
	popd
	set -a
	set -euo pipefail
}


r_intent_run() {
	local r_intent r_line
	r_intent="$1"
	r_line="$2"

	export OPT_intent="$r_intent"
	OPT_intents=("$r_intent" "${OPT_intents[@]:0:10}")
	export OPT_line="$r_line"

	local r_todo
	# g section is _always_ executing
	r_todo=$(snt_get "g" ; snt_get "$r_intent")

	local r_opts
	r_opts=$(<<<"$r_line" json_to_opts | paste -sd' ') ||:
	eval "$r_opts" ||:
	L_log "$r_line"
	L_log "Handling $r_intent with $r_opts"

	r_intent_confirm_check

	local r_tmp r_name r_opt r_cmd
	while
		IFS= read -u10 -r r_name &&
		IFS= read -u10 -r r_opt &&
		IFS= read -u10 -r r_cmd
	do {
		export OPT_name=$r_name
		export OPT_opt=$r_opt
		export OPT_cmd=$r_cmd
		L_log "OPT_name=$r_name OPT_opt=$r_opt OPT_cmd=$r_cmd"
		case "$r_opt" in
		say) 
			r_tmp=$(envsubst <<<"$r_cmd")
			rhasspy_say "$r_tmp"
			;;
		notify)
			tmp=$(envsubst <<<"$r_cmd")
			notify "$r_tmp"
			;;
		saynotify|notifysay)
			tmp=$(envsubst <<<"$r_cmd")
			rhasspy_say "$r_tmp"
			notify "$r_tmp"
			rhasspy_wait_for_say_finished
			;;
		run)
			notify "$r_cmd"
			r_intent_exe "$r_cmd"
			;;
		confirmyes)
			r_intent_confirm "$r_cmd"
			;;
		*)
			notify "Unknown command $r_opt for $r_name with $r_cmd"
			;;
		esac
	} 10<&-; done 10<<<"$r_todo"

	r_intent_confirm_post
}

job_handle_intents() {
	L_name+=": intenthandler"
	trap 'jobs_kill ; L_log quit' EXIT
	local r_intents
	r_intents=$(snt_list | paste -sd' ')
	L_log "Watching intents: $r_intents"
	L_run rhasspy_subscribe -t hermes/intent/'#' | {
		OPT_intents=()
		while
			IFS= read -u 11 -r r_line &&
			r_intent=$(jq -r .intent.intentName <<<"$r_line" | sed 's/[[:space:]]/_/g')
		do
			r_intent_run "$r_intent" "$r_line" ||:
		done
	} 11<&0 0<&-
}

###############################################################################

job_retrain() {
	L_name+=": retrainer"
	trap 'jobs_kill ; L_log quit' EXIT
	L_log "Retraining Rhasspy..."
	if ! rhasspy_retrain; then
		L_fatal "Could not retrain Rhasspy"
	fi
}

###############################################################################

jobs_kill() {
	L_kill_all_jobs
}

###############################################################################

C_say() { rhasspy_say "$@"; }
C_pub() { rhasspy_publish "$@"; }
C_sub() { rhasspy_subscribe "$@"; }
C_handle_intents() { job_handle_intents "$@"; }
C_list_actions() { snt_parser '{print name "\t" opt "\t" cmd}'; }
C_wait_for_say_finished() { rhasspy_wait_for_say_finished "$@"; }
C_run() {
	trap 'jobs_kill ; exit 0 ; L_log exiting' EXIT
	L_log "Running jobs..."
	if [[ "${1:-}" = "train" ]]; then
		# Do not retrain on first start
		job_retrain &
	fi
	job_silence_audio_when_detecting_words &
	job_handle_intents &
	wait
}
C_watcher() {
	trap 'jobs_kill ; kill 0 ; L_log exiting' EXIT
	L_log "Starting monitoring of $0 and $RHASSPY_BINDKEYS_CONFIGFILE ..."
	#
	inotifywait -m -q -e close_write,moved_to --no-newline --format "%w%f%0" \
			"$(dirname "$0")" "$(dirname "$RHASSPY_BINDKEYS_CONFIGFILE")" | {
		trap 'jobs_kill' EXIT
		# Run initial run.
		"$0" "$@" run &
		while IFS= read -r -d '' file; do
			# L_log "$file"
			if [[ "$file" = "$0" ]]; then
				kill -SIGUSR1 $$
			elif [[ "$file" = "$RHASSPY_BINDKEYS_CONFIGFILE" ]]; then
				L_log "config refresh event: $RHASSPY_BINDKEYS_CONFIGFILE"
				jobs_kill
				"$0" "$@" run train &
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
export RHASSPY_BINDKEYS_CONFIGFILE="${RHASSPY_BINDKEYS_CONFIGFILE:-"$HOME/.config/rhasspy/profiles/en/intents/rhasspy_bindkeys_sentences.ini"}"
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
	shift
done

load_user_config

. ,lib_lib C_ "$@"

	









