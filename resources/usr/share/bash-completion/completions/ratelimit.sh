#!/bin/bash

complete -W "$(ratelimit.sh -h | grep '^ ' | tr ' ' '\n' | grep '^-' | cut -d= -f1 | sed 's/,$//' | tr '\n' ' ')" ratelimit.sh


