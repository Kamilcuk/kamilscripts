#!/bin/sh
# kamilscripts_ssh_config.sh
# vim: ft=sshconfig

cat <<'EOF'
# ----- snip ------
# DO NOT EDIT
# UUIDMARK 6b248e21-6024-4544-8051-35cb3e3d2c4c
# This part is checked with kamilscripts/bin/,ssh.sh script!
# ----- snip ------

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
	ProxyJump biurek

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
	ProxyJump dyzio
Host lenovo
	Hostname 192.168.20.11
	User henryk
	ProxyJump dyzio

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
	Compression Yes
	User docker
Host netemera
	Hostname production-0.netemera.com
	Compression Yes
	User kcukro

# NCBJ
Host *.cis.gov.pl
	User kcukrowski
Host dudek dudek.cis.gov.pl dzik dzik.cis.gov.pl jenot jenot.cis.gov.pl kumak kumak.cis.gov.pl leszcz leszcz.cis.gov.pl wilga wilga.cis.gov.pl bocian bocian.cis.gov.pl
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

Host *
	Compression yes
	Ciphers aes128-cbc,aes192-cbc,aes128-ctr,aes256-cbc,aes192-ctr,aes256-ctr,3des-cbc
	ServerAliveInterval 30
	ServerAliveCountMax 3

EOF
