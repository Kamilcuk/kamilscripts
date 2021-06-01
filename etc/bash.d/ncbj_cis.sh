
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
	}
	-re "Last login:" {
	}
	-re "$ " {
		interact
	}
}
return
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

cis-ssh() { ( _cis_ssh_config; ,sshload --i --p ~/ncbj/password.txt -F "$tmp" "$@"; ); }
. alias_complete.sh cis-ssh ssh
cis-scp() { ( _cis_ssh_config; sshpass -f ~/ncbj/password.txt scp -F "$tmp" "$@"; ); }
. alias_complete.sh cis-scp scp
cis-sshfs() { ( _cis_ssh_config;
	sshfs -o ssh_command="sshpass -f ~/ncbj/password.txt ssh -F $tmp" "$@";
); }
. alias_complete.sh cis-sshfs sshfs
cis-rsync() { ( _cis_ssh_config; 
	rsync -e "sshpass -f ~/ncbj/password.txt ssh -F $tmp" "$@";
); }
. alias_complete.sh cis-rsync scp

