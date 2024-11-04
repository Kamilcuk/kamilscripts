#!/usr/bin/env python3

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--option", metavar="blabla", required=True)
parser.add_argument("--opverbose", action="store_true")
parser.add_argument("bar", nargs=3, help="this is a bar argument", type=int)
parser.parse_args()

