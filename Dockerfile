FROM library/archlinux:base-devel
RUN \
    pacman -Suy --needed --noconfirm \
		tar python awk grep gettext make diffutils bc && \
    echo "$BASH_VERSION"

