#!/usr/bin/python
from fcntl import ioctl;
from sys import argv;
from os import open, O_WRONLY, close;
if len(argv) != 2:
  print("Usage: usbreset.py /dev/bus/usb/?/?");
  exit(1);
filename = argv[1]; 
fd = open(filename, O_WRONLY);
USBDEVFS_RESET = ord('U') << (4*2) | 20
ioctl(fd, USBDEVFS_RESET, 0);
close(fd);

