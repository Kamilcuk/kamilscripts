#!/bin/bash
echo "Running grub-mkconfig -o /boot/grub/grub.cfg" >&2
exec grub-mkconfig -o /boot/grub/grub.cfg

