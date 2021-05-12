# https://wiki.archlinux.org/title/Proxy_server

,proxy_on() {
	local proxy="$*"
	export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
	export http_proxy="$proxy" \
		https_proxy="$proxy" \
		ftp_proxy="$proxy" \
		rsync_proxy="$proxy" \
		HTTP_PROXY="$proxy" \
		HTTPS_PROXY="$proxy" \
		FTP_PROXY="$proxy" \
		RSYNC_PROXY="$proxy"
	echo "Proxy environment variable set."
}

,proxy_off(){
	unset http_proxy https_proxy ftp_proxy rsync_proxy
	unset HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY
	echo "Proxy environment variable removed."
}

