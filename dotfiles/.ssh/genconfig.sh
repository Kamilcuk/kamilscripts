#!/bin/sh
# ~/.ssh/genconfig.sh
# vim: ft=sshconfig

tab() {
	echo $'\t'"$*"
}

hascmd() {
	hash "$@" >/dev/null 2>&1
}

ssh_version=$(
	ssh -V 2>&1 |
	tr '[A-Z]' '[a-z]' |
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
	[[ "$HOSTNAME" =~ \.cis\.gov\.pl$ ]]
}

###############################################################################

cat <<EOF
Host config rmcontrol
	Host 255.255.255.255
	ProxyCommand false
EOF

###############################################################################

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

Host perun
	Hostname karta.dyzio.pl
	# 2a02:c207:2050:3924::1 207.180.196.233
	User root
	Port 60022

EOF

fi # is_cis

###############################################################################

cat <<EOF
Host gitlab.com github.com
	User git
	$([[ -e ~/.ssh/github_id_rsa ]] && echo "IdentityFile ~/.ssh/github_id_rsa")
	$(is_cis && hascmd ncat &&
			echo "ProxyCommand ncat --proxy 127.0.0.1:60000 --proxy-type socks5 %h %p"
	)
EOF

###############################################################################

if [[ "$HOSTNAME" != gucio ]]; then

cat <<EOF
# NCBJ
Host *.cis.gov.pl *_cis
	User kcukrowski
	GSSAPIAuthentication yes
	GSSAPIDelegateCredentials yes
EOF


dectempl ncbj '
Host cis-$1 $1 $1-cis $1.cis.gov.pl
	Hostname ${2:-$1.cis.gov.pl}
	User ${3:-kcukrowski}
	GSSAPIAuthentication yes
	GSSAPIDelegateCredentials yes
	$(is_cis || echo RemoteForward 60000)
	ExitOnForwardFailure no
	ForwardX11 yes
	ForwardX11Trusted yes
	StrictHostKeyChecking no
	${4:+$4}
'
# https://great-idea.atlassian.net/wiki/spaces/FMM/pages/234487859/Using+the+FMR+demo+VM
ncbj leszcz
ncbj dzik
ncbj kumak
ncbj bocian
ncbj dudek
ncbj jenot
ncbj wilga
ncbj slimak
ncbj kaczor
#
ncbj usrint2         172.18.0.22
ncbj interactive0001 172.18.128.2
ncbj interactive0002 172.18.128.2
ncbj ui              192.68.51.202      ''   'Port 22222'
ncbj doc             172.18.128.2
ncbj cms-vo          ''
#
ncbj jenkins         dizvm2.cis.gov.pl  root
ncbj teptest         dizvm3.cis.gov.pl  root
ncbj fb_core         dizvm4.cis.gov.pl  root
ncbj fmr             dizvm5.cis.gov.pl  root
ncbj squidproxy      dizvm6.cis.gov.pl  root
ncbj cicd            dizvm7.cis.gov.pl  root
ncbj proxy           dizvm8.cis.gov.pl  root
ncbj grafana         dizvm9.cis.gov.pl  root
ncbj zabbixserver    dizvm11.cis.gov.pl root
ncbj gurobi          dizvm12.cis.gov.pl root
ncbj minio           dizvm13.cis.gov.pl root
ncbj smtp2rest       dizvm13.cis.gov.pl root
ncbj opengrok        dizvm14.cis.gov.pl root
ncbj tester          dizvm15.cis.gov.pl root
ncbj deploycicd      dizvm18.cis.gov.pl root
ncbj chronoscicd     dizvm20.cis.gov.pl root
ncbj nexus           dizvm35.cis.gov.pl root

cat <<EOF
Host code.cis.gov.pl
	User git
	$([[ -e ~/.ssh/cis_code_id_rsa ]] && echo "IdentityFile ~/.ssh/cis_code_id_rsa")

$([[ -e ~/.ssh/id_rsa_zwierzaki ]] && cat <<EOF2
Match host=*.cis.gov.pl
	IdentityFile ~/.ssh/id_rsa_zwierzaki
EOF2
)

Match host=*.cis.gov.pl user=root
	PasswordAuthentication no

Host zwierzakauto
	Hostname proxy.services.idea.edu.pl
	Port 10022
	StrictHostKeyChecking no
	UserKnownHostsFile  ~/.ssh/zwierzakauto_known_hosts
	ControlMaster auto
	ControlPath  ~/.ssh/.socket_%r@%h-%p
	ControlPersist 1w
	User kcukrowski

Host lightsail1
	User kcukrowski
	Hostname 3.69.31.141

Host kgomulskirpi rpichronos01
	User root
	Hostname 10.135.0.3
Host rpichronos02
	User root
	Hostname 10.135.0.5

EOF

fi

###############################################################################

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
	#
	ServerAliveInterval 60
	ServerAliveCountMax 20
	# https://www.tecmint.com/speed-up-ssh-connections-in-linux/
	ControlMaster no
	ControlPath  ~/.ssh/.socket_%r@%h-%p
	ControlPersist 6000
	#
	ExitOnForwardFailure yes

EOF
