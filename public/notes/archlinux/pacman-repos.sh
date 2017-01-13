# archzfs

cat >/etc/pacman.conf <<EOF

[archzfs]
Server = http://archzfs.com/\$repo/x86_64
EOF

# archlinuxfr

cat >/etc/pacman.conf <<EOF

[archlinuxfr]
Server = http://repo.archlinux.fr/\$arch
SigLevel    = Optional TrustedOnly
EOF

