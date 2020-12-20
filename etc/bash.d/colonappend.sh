#!/bin/bash

,colonappend() {
	local var
	var="$1"
	for i; do
		case ":$var:" in
		":$i:") ;;
		*) var="${var:+$var:}$i"; ;;
		esac
	done
	printf "%s\n" "$var"
}

,colonprepend() {
	local var
	var="$1"
	for i; do
		case ":$var:" in
		":$i:") ;;
		*) var="$i${var:+:$var}"; ;;
		esac
	done
	printf "%s\n" "$var"
}

