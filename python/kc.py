#!/usr/bin/env python3

import os
import signal

import click


def runshell(str):
    import subprocess

    subprocess.check_call("bash -xeuo pipefail -c".split() + [str])


def atexit_killpg():
    os.killpg(0, signal.SIGKILL)


def shlex_join(arr: list):
    import shlex

    return " ".join(shlex.join(x) for x in arr)


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
