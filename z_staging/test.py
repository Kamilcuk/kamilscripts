#!/usr/bin/env python3

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--ab", action="store_true")
parser.add_argument("bar", nargs=3)
parser.parse_args()

