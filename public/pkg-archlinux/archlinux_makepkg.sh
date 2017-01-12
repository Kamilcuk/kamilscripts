#!/bin/bash

DIR=$(readlink -f $(dirname $(readlink -f $0)))
export PACKAGER="Kamil Cukrowski <kamilcukrowski@gmail.com>"
makepkg

