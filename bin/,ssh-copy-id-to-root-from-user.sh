#!/bin/bash

ssh "$1" sudo tee -a /root/.ssh/authorized_keys < ~/.ssh/id_rsa.pub 

