
if [[ $- != *i* ]]; then return; fi

_cis_expect() {
	expect -f <(cat <<'EOF'
# https://askubuntu.com/questions/93848/ssh-shell-launched-using-expect-doesnt-have-full-width-how-can-i-make-fix-it
# trap sigwinch and pass it to the child we spawned
trap {
	set rows [stty rows]
	set cols [stty columns]
	stty rows $rows columns $cols < $spawn_out(slave,name)
} WINCH

set args [lrange $argv 0 end]
spawn {*}$args

expect {
	-re "The authenticity of .* can't be established." {
		send "yes"
		send "\r"
		exp_continue
	}
	-re ".*assword:" {
		set pass [read [open "~/ncbj/password.txt"]]
		send -- $pass
		send -- "\r"
		interact
		return
	}
	-re "Last login:" {
		interact
		return
	}
	-re "$ " {
		interact
		return
	}
}
# interact
# expect eof
EOF
	) "$@"
}
_cis_sshpass() {
	sshpass -f ~/ncbj/password.txt "$@"
}
_cis_ssh_config() {
	tmp=$(mktemp --tmpdir .cis-ssh-config.XXXXXXXXXXX)
	trap "rm $(printf "%q" "$tmp")" exit
	{ cat - /etc/ssh/ssh_config ~/.ssh/config <<'EOF'; } 2>/dev/null >"$tmp" ||:
Host *
	User kcukrowski
EOF
}

cis-ssh() { ( _cis_ssh_config; sshpass -f ~/ncbj/password.txt ssh -F "$tmp" "$@"; ); }
. alias_complete.sh cis-ssh ssh
cis-scp() { ( _cis_ssh_config; _cis_expect scp -F "$tmp" "$@"; ); }
. alias_complete.sh cis-scp scp
cis-sshfs() { ( _cis_ssh_config;
	sshfs -o ssh_command="sshpass -f ~/ncbj/password.txt ssh -F $tmp" "$@";
); }
. alias_complete.sh cis-sshfs sshfs
cis-rsync() { ( _cis_ssh_config; 
	rsync -e "sshpass -f ~/ncbj/password.txt ssh -F $tmp" "$@";
); }
. alias_complete.sh cis-rsync scp

if false; then
_cis-ssh-smart() {
	local args
	args=$(getopt -o ::46AaCfGgKkMNnqsTtVvXxYyB:b:c:D:E:e:F:I:i:J:L:l:m:O:o:p:Q:R:S:W:w: -- "$@")
	set -- "$args"
	args=()
	while (($#)); do
		case "$1" in
		-4|-6|-A|-a|-C|-f|-G|-g|-K|-k|-M|-N|-n|-q|-s|-T|-t|-V|-v|-X|-x|-Y|-y) args+=("$1"); ;;
		-B|-b|-c|-D|-E|-e|-F|-I|-i|-J|-L|-l|-m|-O|-o|-p|-Q|-R|-S|-W|-w) args+=("$1" "$2"); shift; ;;
		--) shift; break; ;;
		*) echo "ERROR" >&2; return 1; ;;
		esac
		shift
	done
	local server=$1
	if [[ ! "$server" =~ '@' ]]; then
		server="kcukrowski@$server"
	fi
	ssh "${args[@]}" "$server" "$@"
}
fi

