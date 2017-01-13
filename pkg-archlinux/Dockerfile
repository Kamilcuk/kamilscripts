FROM finalduty/archlinux:daily
RUN  echo '[archlinuxfr]' >> /etc/pacman.conf && \
  echo 'Server = http://repo.archlinux.fr/$arch' >> /etc/pacman.conf && \
  echo 'SigLevel    = Optional TrustedOnly' >> /etc/pacman.conf && \
  pacman -Sy --needed --noconfirm yaourt && \
  yaourt -S --needed --noconfirm base-devel pacutils git rsync
RUN  yes Y | pacman -Sc && yes Y | pacman -Scc
