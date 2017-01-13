# create arch rescue chrot

## pre
rm /boot/*
rm /etc/mkinitcpio.d/linux.preset
ln -s /dev/null /etc/mkinitcpio.d/linux.preset
pacman -S vim

## see smaller_filesystem
## see getty
## customization

