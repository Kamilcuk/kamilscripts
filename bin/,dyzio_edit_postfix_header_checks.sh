#!/bin/bash
ssh -t root@dyzio 'set -x ; vim /etc/postfix/header_checks ; postmap /etc/postfix/header_checks'

