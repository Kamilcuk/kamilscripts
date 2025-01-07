#!/bin/bash
# shellcheck disable=SC2016
# ~/.ssh/genconfig.sh
# vim: ft=sshconfig fdm=marker
# {{{1

tab() {
	echo $'\t'"$*"
}

hascmd() {
	hash "$@" >/dev/null 2>&1
}

ssh_version=$(
	LC_ALL=C ssh -V 2>&1 |
	tr 'A-Z' 'a-z' |
	sed 's/^openssh_\([0-9]*\).\([0-9]*\).*/\1.\2/'
)

ssh_check_ver() {
	if awk "BEGIN{exit(!($ssh_version $1 $2))}" <&-; then
		shift 2
		printf "%s\n" "$@"
	fi
}

ProxyJump() {
	ssh_check_ver '>=' 7.3 "ProxyJump $*"
}


# Add a template function with <name> and <content>
dectempl() {
	local a
	# Remove leading and trailing lines with whitespaces.
	#a=$(sed -Ez 's/^([[:space:]]*\n)*//; s/(\n[[:space:]]*)*\n$//' <<<"$2")
	a=$(sed ':a; /[^[:blank:]]/,$!d; /^[[:space:]]*$/{ $d; N; ba; }' <<<"$2")
	eval "
$1() {
	cat <<EOF
$a
EOF
}
"
}

is_cis() {
	[[ "$HOSTNAME" == *".cis.gov.pl" ]]
}

# {{{1 ##############################################################################

cat <<EOF
Host config removecontrol
	Hostname 255.255.255.255
	ProxyCommand false
EOF

# {{{1 ##############################################################################

if ! is_cis; then

cat <<EOF
Host dyzio server
	Hostname www.dyzio.pl
	User kamcuk
	Port 4004
Host tunel_dyzio
	Hostname 192.168.20.1
	User kamcuk
	Port 4004

Host biurek gucio
	Hostname www.biurek.pl
	$(ssh_check_ver '>' 6.0 '
	PubkeyAcceptedKeyTypes +ssh-rsa
	')
	User kamil
	Port 4004
Host tunel_biurek
	Hostname 192.168.21.1
	User kamil
	Port 4004
Host kurczak
	Hostname 192.168.31.1
	User root
	Port 22
	#$(ProxyJump biurek)
Host pantera
	# Hostname 192.168.31.1
	Hostname 192.168.48.1
	User root
	Port 22
	$(ProxyJump biurek)

Host polel
	Hostname 192.168.0.14
	User root

Host wujek hercules Hercules
	Hostname pi.mini.pw.edu.pl
	User kamil
	Port 10022
Host tunel_wujek
	Hostname 192.168.1.1
	User kamil
	Port 10022
# Writual serverw ith archlinux on Hercules
Host asteria
	$(ProxyJump wujek)
	Hostname localhost
	User root
	Port 60022
	StrictHostKeyChecking no
	UserKnownHostsFile /dev/null

#Host chors
	#Hostname 193.33.111.225
	#User root
	#Port 60022

# tunels
Host leo leonidas tunel_leonidas
	Hostname 192.168.255.32
	User kamil
Host gorgo tunel_gorgo
	Hostname 192.168.255.33
	User kamil
Host ardalus tunel_ardalus
	Hostname 192.168.255.35
	User kamil
Host alpinezfssmb tunel_alpinezfssmb
	Hostname 192.168.255.36
	User kamil
Host tunel_chors
	Hostname 192.168.255.50
	User root

Host galeranew
	Hostname galeranew.ii.pw.edu.pl
	User kcukrows
Host mion
	Hostname mion.elka.pw.edu.pl
	user kcukrows

Host michal
	Hostname 192.168.20.7
	User kamil
	$(ProxyJump dyzio)
Host lenovo
	Hostname 192.168.20.11
	User henryk
	$(ProxyJump dyzio)
Host beta
	Hostname 192.168.21.101
	User henryk
	$(ProxyJump biurek)


#Host ustro
#	Hostname ustropecet.ustronie.ds.pw.edu.pl
#	Hostname pecet123.ustronie.ds.pw.edu.pl
#	Hostname 10.3.254.208
#	User kamil
#Host ustrotunel
#	Hostname 192.168.255.33
#	User kamil
#	port 4004

Host aur.archlinux.org
	IdentityFile ~/.ssh/aur_id_rsa
	User aur

Host leonidas_borowej_gory
	Hostname 192.168.0.2
Host gorgo_borowej_gory
	Hostname 192.168.0.6

# netemera
Host netemeradocker
	Hostname production-0.netemera.com
	User docker
Host netemera
	Hostname production-0.netemera.com
	User kcukro

# Host perun
# 	#Hostname karta.dyzio.pl
# 	#Hostname kamcuk.top
# 	# 2a02:c207:2050:3924::1
# 	Hostname 207.180.196.233
# 	Port 60022
# 	ForwardX11 yes
#
# Host perunshare
# 	Hostname kamcuk.top
# 	User share
# 	Port 60022

Host mx1
	Hostname 192.168.21.12
	User kamil

Host weles perun
	Hostname 212.90.120.55
	User kamil
	Port 60022

EOF

fi # is_cis

###############################################################################

cat <<EOF
Host gitlab.com github.com
	User git
	# $([[ -e ~/.ssh/github_id_rsa ]] && echo "IdentityFile ~/.ssh/github_id_rsa")
	$(is_cis && hascmd ncat &&
			echo "ProxyCommand ncat --proxy 127.0.0.1:60000 --proxy-type socks5 %h %p"
	)
EOF

# {{{1 ##############################################################################

cat <<EOF
Host st-ssh-bastion.striketechnologies.com
	User kcukrowski
	Hostname 172.29.140.179
	IdentityFile ~/.ssh/bastion_id_rsa
	PubkeyAcceptedKeyTypes +ssh-rsa
	RequestTTY yes
Match host "*.striketechnologies.com,*lxavt*[dp]"
	PubkeyAcceptedKeyTypes +ssh-rsa
	HostKeyAlgorithms +ssh-rsa
EOF
case $HOSTNAME in kcukrowski-ph*) cat <<EOF
Host *
	EscapeChar !
EOF
	;;
esac

# {{{1 ##############################################################################

cat <<EOF

Host *
	#$(
	echo; for i in ~/.ssh/id_rsa*; do
		[[ ! -e "$i" ]] || ! grep -q "PRIVATE KEY" "$i" && continue
		tab "IdentityFile $i"
	done)
	#
	# https://www.systutorials.com/improving-sshscp-performance-by-choosing-ciphers/
	# http://homepages.warwick.ac.uk/staff/E.J.Brambley/sshspeedtest.php
	$(ssh_check_ver '>=' 7.0 'Ciphers aes128-cbc,aes128-ctr,aes192-cbc,aes192-ctr,aes256-cbc,aes256-ctr,3des-cbc,aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com')
	$(ssh_check_ver '<' 7.0 'Ciphers aes128-cbc,aes128-ctr,aes192-cbc,aes192-ctr,aes256-cbc,aes256-ctr,3des-cbc')
	#
	Compression yes
	ExitOnForwardFailure yes
	#
	ServerAliveInterval 60
	ServerAliveCountMax 20
	$(ssh_check_ver '>' 6.0 '
	# https://www.tecmint.com/speed-up-ssh-connections-in-linux/
	ControlMaster auto
	#ControlPath  ~/.ssh/.connection-%n-%r@%h:%p
	ControlPath  ~/.ssh/.c-%C
	ControlPersist 1h
	StrictHostKeyChecking accept-new
	ConnectTimeout 2
	')

EOF
