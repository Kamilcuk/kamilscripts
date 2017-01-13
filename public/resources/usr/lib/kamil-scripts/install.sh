#!/bin/bash


[ -f /etc/bash.bashrc ] && \
	! grep -qe ". /usr/lib/kamil-scripts/bash.bashrc" >/dev/null 2>&1 && \
		echo -ne "\n. /usr/lib/kamil-scripts/bash.bashrc\n" >> /etc/bash.bashrc
