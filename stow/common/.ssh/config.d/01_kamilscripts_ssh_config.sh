#!/bin/sh
# kamilscripts_ssh_config.sh
# vim: ft=sshconfig

ssh_get_version() {
	if [[ -z "$ssh_version" ]]; then
		ssh_version=$(
			ssh -V 2>&1 |
			tr '[A-Z]' '[a-z]' |
			sed 's/^openssh_\([0-9]*\).\([0-9]*\).*/\1.\2/'
		)
	fi
}
ssh_get_version

ssh_check_ver() {
	local tmp
	tmp=$(echo "$ssh_version $1 $2" | bc)
	if grep -qi error <<<"$tmp"; then
		echo "ERROR: ssh_check_ver in $BASH_SOURCE" >&2
		return 1
	fi
	if (($tmp)); then
		shift 2
		printf "%s\n" "$@"
	fi
}

ProxyJump() {
	ssh_check_ver '>=' 7.3 "ProxyJump $*"
}


# Add a template function with <name> and <content>
templ() {
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

###############################################################################

cat <<EOF
Host dyzio
	Hostname www.dyzio.pl
	User kamcuk
	Port 4004
Host dyzio_root
	Hostname www.dyzio.pl
	User root
	Port 4004
Host tunel_dyzio
	Hostname 192.168.20.1
	User kamcuk
	Port 4004
Host tunel_dyzio_root
	Hostname 192.168.20.1
	User root
	Port 4004

Host biurek
	Hostname www.biurek.pl
	User kamil
	Port 4004
	Compression yes
Host biurek_root
	Hostname www.biurek.pl
	User root
	Port 4004
Host tunel_biurek
	Hostname 192.168.21.1
	User kamil
	Port 4004
Host tunel_biurek_root
	Hostname 192.168.21.1
	User kamil
	Port 4004
Host kurczak
	Hostname 192.168.21.21
	User kamil
	Port 22
	$(ProxyJump biurek)

Host wujek hercules Hercules
	Hostname pi.mini.pw.edu.pl
	User kamil
	Port 10022
Host tunel_wujek
	Hostname 192.168.1.1
	User kamil
	Port 10022
Host chors
	Hostname 193.33.111.225
	User root
	Port 60022

# tunels
Host leo leonidas tunel_leonidas
	Hostname 192.168.255.32
	User root
Host gorgo tunel_gorgo
	Hostname 192.168.255.33
	User root
Host ardalus tunel_ardalus
	Hostname 192.168.255.35
	User root
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

#Host ustro
#	Hostname ustropecet.ustronie.ds.pw.edu.pl
#	Hostname pecet123.ustronie.ds.pw.edu.pl
#	Hostname 10.3.254.208
#	User kamil
Host ustrotunel
	Hostname 192.168.255.33
	User kamil
	port 4004

Host aur.archlinux.org
	IdentityFile ~/.ssh/aur_id_rsa
	User aur

Host leonidas_borowej_gory
	Hostname 192.168.0.2
Host gorgo_borowej_gory
	Hostname 192.168.0.6

Host gitlab.com github.com
	IdentityFile ~/.ssh/github_id_rsa

# netemera
Host netemeradocker
	Hostname production-0.netemera.com
	Compression yes
	User docker
Host netemera
	Hostname production-0.netemera.com
	Compression yes
	User kcukro
EOF

###############################################################################

cat <<EOF
# NCBJ
Host *.cis.gov.pl *_cis
	User kcukrowski
	GSSAPIAuthentication=yes
	GSSAPIDelegateCredentials yes

EOF


templ ncbj '
Host $1_cis
	Hostname ${2:-$1.cis.gov.pl}${3:+
	$3}
'
ncbj   leszcz            10.200.4.5
ncbj   dzik              10.200.4.4
ncbj   kumak             10.200.4.3
ncbj   bocian            10.200.4.11
ncbj   dudek             10.200.4.12
ncbj   jenot             10.200.4.13
ncbj   wilga             10.200.4.14
ncbj   usrint2           172.18.0.22
ncbj   interactive0001   172.18.128.2
ncbj   interactive0002   172.18.128.2
ncbj   ui                192.68.51.202  'Port 22222'
ncbj   doc               172.18.128.2
ncbj   cms-vo ''
# https://great-idea.atlassian.net/wiki/spaces/FMM/pages/234487859/Using+the+FMR+demo+VM
ncbj   dizvm5  10.200.4.205

cat <<EOF
Host code.cis.gov.pl
	IdentityFile ~/.ssh/cis_code_id_rsa
EOF

###############################################################################

cat <<EOF

Host *
	Compression yes
	Ciphers aes128-cbc,aes192-cbc,aes128-ctr,aes256-cbc,aes192-ctr,aes256-ctr,3des-cbc
	ServerAliveInterval 30
	ServerAliveCountMax 3

EOF
