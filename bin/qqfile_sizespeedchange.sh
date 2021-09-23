#!/bin/bash

file=$1
sec=${2:-60}

last=0; sec=60;
while true; do
       	now=$(stat -f %s "$file");
	echo "last=$last now=$now $((last-now)) [B/${sec} s] -OR- $(((last-now)/sec)) [B/s]";
       last=$now; 
       sleep $sec;
done

