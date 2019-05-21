#!/bin/bash

file=$1
sec=${2:-60}

size() { ls -l $file | awk '{print $5}'; }; 
last=0; sec=60;
while true; do
       	now=$(size); 
	echo "last=$last now=$now $((last-now)) [B/${sec} s] -OR- $(((last-now)/sec)) [B/s]";
       last=$now; 
       sleep $sec;
done

