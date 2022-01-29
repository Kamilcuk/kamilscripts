#!/bin/bash
set -euo pipefail

r() {
	echo "+ ${*@Q}" >&2
	"$@"
}

reval() {
	echo "+ eval $*" >&2
	eval "$*"
}

fatal() {
	echo "$0: ERROR: $*" >&1
	exit 1
}

safecd() {
	if ! cd "$1"; then
		fatal "Could not cd to $1"
	fi
}

ffmpeg=(ffmpeg -nostdin -hide_banner -y -nostats -loglevel warning)

getdate() {
	date +%Y-%m-%dT%H:%M:%S
}

kill_all_childs() {
	tmp="$(jobs -p)" || :
	if [[ -n "$tmp" ]]; then
		# shellcheck disable=2086
		kill $tmp 2>/dev/null || :
	fi
	r wait || :
}

ffmpeg_concat2() {
	r "${ffmpeg[@]}" \
		-i "$1" -i "$2" \
		-filter_complex "[0:v:0] [0:a:0] [1:v:0] [1:a:0] concat=n=2:v=1:a=1 [v] [a]" -map "[v]" -map "[a]" \
		"$3"
}

ffmpeg_speedup() {
	# https://superuser.com/questions/1261678/how-do-i-speed-up-a-video-by-60x-in-ffmpeg
	local speedup setpts inf outf
	speedup=$1
	inf=$2
	outf=$3
	setpts=$(awk -v value="$speedup" 'BEGIN{ printf("%.2f\n", 1/value); exit; }')
	r "${ffmpeg[@]}" \
		-i "$inf" \
		-filter_complex "[0:v]setpts=${setpts}*PTS[v];[0:a]atempo=${speedup}[a]" -map "[v]" -map "[a]" \
		"$outf"
}

remote_updatestate() {
	umask 002
	safecd ~/work
	#
	rawf="tmp/raw/$filename"
	#
	{
		# Create a big all filename
		mkdir -p tmp/all tmp/tmp
		rawallf="tmp/all/rawall_$starttime.avi"
		rawtmpf="tmp/tmp/raw_$filename"
		if [[ ! -e "$rawallf" ]]; then
			r cp -v "$rawf" "$rawallf"
		else
			ffmpeg_concat2 "$rawallf" "$rawf" "$rawtmpf"
			r mv -vf "$rawtmpf" "$rawallf"
		fi
		# Create symlink
		r ln -vfs "$rawallf" rawall_latest.avi
	} &
	#
	{
		mkdir -pv tmp/speed
		speedf="tmp/speed/speed_$filename"
		# Speed up
		ffmpeg_speedup 20 "$rawf" "$speedf"
		# Create speeded filename
		endtime=$(getdate)
		speedallf="tmp/all/speedall_${starttime}=${endtime}.avi"
		speedlatestf="speedall_latest.avi"
		if [[ ! -e "$speedlatestf" ]]; then
			r cp -v "$speedf" "$speedallf"
		else
			ffmpeg_concat2 "$speedlatestf" "$speedf" "$speedallf"
		fi
		r rm -fv "$speedf"
		# Create symlink
		r ln -vfs "$speedallf" "$speedlatestf"
	} &
	#
	r wait || :
	r rm -fv "$rawf"
}

remote_finishstate() {
	umask 002
	safecd ~/work
	#
	mkdir -p archive
	#
	archiveit() {
		local src dest
		src=$(readlink "$1")
		dest="archive/$2"
		r mv -v "$src" "$dest"
		r ln -vfs "$dest" "$1"
	}
	#
	endtime=$(getdate)
	archiveit rawall_latest.avi    "raw_${starttime}=${endtime}.avi"
	archiveit speedall_latest.avi  "speed_${starttime}=${endtime}.avi"
	#
	shopt -s nullglob
	r rm -vr tmp || :
}

remoterun() {
	local tmp1 tmp2 script
	tmp1=$(declare -p filename ffmpeg starttime) || fatal "declare -p"
	tmp2=$(declare -f ffmpeg_concat2 ffmpeg_speedup r reval getdate kill_all_childs \
			remote_updatestate remote_finishstate safecd fatal
	) || fatal "declare -f"
	script="
		exec 1>&2
		$tmp1
		$tmp2
		$1
	"
	r wait || :
	# shellcheck disable=2029
	ssh polel@perun "$(printf "%q " bash -c "$script")" &
}

updatestate() {
	remoterun remote_updatestate
}

finishstate() {
	remoterun remote_finishstate
}

recorder() {
	umask 002
	trap_exit() {
		finishstate || :
		kill_all_childs || :
	}
	trap 'trap_exit' EXIT
	trap 'trap_exit ; exit' INT
	#
	chunklensec=60
	filelensuffix="${chunklensec}sec"
	#
	cmd=(
		"${ffmpeg[@]}"
		# -stats
		-f v4l2
		-thread_queue_size 0
		-r 30
		-s 640x480
		-i /dev/video0
		-channel_layout mono
		-f pulse
		-i "$(sudo pactl list short sources | awk '/OmniVision/{print $2}')"
		-t "$chunklensec"
	)
	starttime=$(getdate)
	dir="/mnt/perunshare/salonrecord"
	#dir=/srv/samba
	safecd "$dir"
	mkdir -pv tmp/raw
	while true; do
		filename="$(getdate)_$filelensuffix.avi"
		r "${cmd[@]}" "file:tmp/raw/$filename"
		updatestate "$starttime" "$filename"
	done
}

loop() {
	umask 002
	trap 'kill_all_childs' EXIT
	trap 'kill_all_childs || : ; exit' INT
	#
	set -euo pipefail
	gpio=21
	gpio -g mode "$gpio" in
	gpio -g mode "$gpio" up
	state=0
	while sleep 1; do
		cur=$(gpio -g read "$gpio")
		# echo "cur=$cur state=$state"
		#
		if (( cur != state )); then
			if ((cur)); then
				r recorder &
				child=$!
			else
				r kill -s INT %1 "$child" || :
			fi
		fi
		state="$cur"
	done
}

###############################################################################

case "$1" in
loop) loop; ;;
rec) recorder; ;;
remoteloop|remoterec)
	r scp "$0" polel:/root/bin/rpirecorder.sh
	r ssh -t polel /root/bin/rpirecorder.sh "${1#remote}"
	;;
cleanfast)
	r ssh perun 'cd /share/salonrecord && rm -vr tmp'
	;;
*) echo "Usage: $0 <loop|rec|remoterec|cleanfast>"; exit 1; ;;
esac


