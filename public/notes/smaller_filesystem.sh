# remove unused packages
pacman -R man-db

# remove dhcpcd + systemd enable+fix
pacman -R netctl dhcpcd
systemctl enable systemd-networkd
cat > /etc/systemd/network/alldhcp.network << EOF
[Match]
Name=en*

[Network]
DHCP=ipv4
EOF

# remove openresolv -> move to systemd-resolved
pacman -R openresolv
systemctl enable systemd-resolved
rm etc/resolv.conf
ln -s /run/systemd/resolve/resolv.conf etc/resolv.conf

# remove pacman cache
yes Y | pacman -Scc
yes Y | pacman -Sc
rm -rf /var/lib/pacman/sync/*

# remove /usr/src -> from dkms linux packages
rm -rf /usr/src/*

# remove includes
rm -rf /usr/include/*

