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

# NCBJ
Host *.cis.gov.pl
	User kcukrowski
Host dudek_cis dudek_cis_gov_pl
	Hostname dudek.cis.gov.pl
	User kcukrowski
Host dzik_cis dzik_cis_gov_pl
	Hostname dzik.cis.gov.pl
	User kcukrowski
Host jenot_cis jenot_cis_gov_pl
	Hostname jenot.cis.gov.pl
	User kcukrowski
Host kumak_cis kumak_cis_gov_pl
	Hostname kumak.cis.gov.pl
	User kcukrowski
Host leszcz_cis leszcz_cis_gov_pl
	Hostname leszcz.cis.gov.pl
	User kcukrowski
Host wilga_cis wilga_cis_gov_pl
	Hostname wilga.cis.gov.pl
	User kcukrowski
Host bocian_cis bocian_cis_gov_pl
	Hostname bocian.cis.gov.pl
	User kcukrowski
Host usrint2 usrint2_cis_gov_pl
	Hostname 172.18.0.22
	User kcukrowski
Host interactive0001 interactive0001_cis_gov_pl
	Hostname 172.18.128.2
	User kcukrowski
Host interactive0002 interactive0002_cis_gov_pl
	Hostname 172.18.128.2
	User kcukrowski
Host ui_cis ui_cis_gov_pl
	Hostname 192.68.51.202
	Port 22222
	User kcukrowski
Host doc_cis doc_cis_gov_pl 
	Hostname 172.17.0.10 
	User kcukrowski
Host licenses_cis licenses_cis_gov_pl
	Hostname 172.17.0.3 
	User kcukrowski
Host repos2_cis repos2_cis_gov_pl
	Hostname 172.18.0.28
	User kcukrowski
Host cms-vo_cis
	Hostname cms-vo.cis.gov.pl
	User kcukrowski
Host pi-inc_cis
	Hostname pi-int.cis.gov.pl
	User kcukrowski
Host code.cis.gov.pl
	Hostname code.cis.gov.pl
	User kcukrowski
	IdentityFile ~/.ssh/github_id_rsa

Host *
	Compression yes
	Ciphers aes128-cbc,aes192-cbc,aes128-ctr,aes256-cbc,aes192-ctr,aes256-ctr,3des-cbc
	ServerAliveInterval 30
	ServerAliveCountMax 3

EOF
