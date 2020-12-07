#!/bin/bash

file=$1
shift
args=()
for i; do
	args+=(-ex "disassemble $i")
done
gdb -batch -ex "file $file" "${args[@]}" <&-

