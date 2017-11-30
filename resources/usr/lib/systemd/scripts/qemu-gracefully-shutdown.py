#!/usr/bin/python

import argparse
import socket
import sys
import time
 
parser = argparse.ArgumentParser()
#parser.add_argument("-v", "--verbose", action="count", default=0, help="Verbose output.")
parser.add_argument("-t", "--timeout", type=int, default=10, help="Shutdown timeout in seconds.")
parser.add_argument("socket", type=str, help="QEMU monitor socket.")
args = parser.parse_args()
 
timeout = False
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
try:
    s.connect(args.socket)
    s.sendall(b"system_powerdown\n")
    t = time.time()
    while True:
        d = time.time() - t
        if d >= args.timeout:
            timeout = True
            break # timeout
        s.settimeout(args.timeout - d)
        try :
            c = s.recv(4096)
            if c == b"":
                break # disconnect
        except socket.timeout:
            timeout = True
            break # timeout
except socket.error as ex:
    print >>sys.stderr, ex
if timeout:
    print >>sys.stderr, "System shutdown timeout for %s." % (args.socket, )
s.close()
