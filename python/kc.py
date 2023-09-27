#!/usr/bin/env python3

import os
import select
import signal
import socket
import time
from typing import Iterable, List, Optional

import click
import requests
from numpy import log


def runshell(str):
    import subprocess

    subprocess.check_call("bash -xeuo pipefail -c".split() + [str])


def atexit_killpg():
    os.killpg(0, signal.SIGKILL)


def shlex_join(arr: list):
    import shlex

    return " ".join(shlex.quote(x) for x in arr)


def read_response_stream(
    response: requests.Response,
    timeout: float = 1,
    separator: str = "\n",
    chunksize: int = 4096,
) -> Iterable[Optional[str]]:
    """
    Read a requests.Response as a stream separated by separator.
    But periodically each timeout seconds output a None.
    """
    finput = socket.fromfd(response.raw.fileno(), socket.AF_INET, socket.SOCK_STREAM)
    print(f"response={response} finput={finput}")
    try:
        finput.setblocking(False)
        now: float = time.time()
        timestop: float = now + timeout
        prevpart: Optional[bytes] = None
        separatorb: bytes = separator.encode()
        while True:
            now: float = time.time()
            selecttimeout: float = min(0, timestop - now)
            r, _, e = select.select([finput], [], [], selecttimeout)
            if finput in e:
                break
            if finput not in r:
                yield None
                continue
            readchunk = finput.recv(chunksize)
            if not readchunk:
                continue
            parts: List[bytes] = readchunk.split(separatorb)
            # Was there something left from previous reading?
            if prevpart:
                parts[0] = prevpart + parts[0]
                prevpart = None
            # Did we read and end on a separator?
            if parts[-1] != "":
                # Remember partial element on next time
                prevpart = parts[-1]
                # And remove it from elements that we read
                parts.pop()
            for p in parts:
                tmp = p.decode() + separator
                print(f"READS: {tmp!r}")
                yield tmp
    finally:
        finput.setblocking(True)


@click.group()
@click.help_option("-h")
def main():
    os.setpgrp()


def command(*args, **kvargs):
    def wrap(f):
        global main
        return main.command(f.__name__, *args, **kvargs)(f)

    return wrap


if __name__ == "__main__":
    pass
