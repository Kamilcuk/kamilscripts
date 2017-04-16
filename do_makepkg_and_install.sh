#!/bin/bash

sudo -u kamil $(dirname $(readlink -f $0))/makepkg.sh -i -f

