#!/bin/bash

if [[ $- != *i* ]]; then return; fi

# Add a wrapper that auto-generates my configuration.
alias ssh=',ssh.sh'

