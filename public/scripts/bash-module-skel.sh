#!/bin/bash
set -euo pipefail

# These are examples of bash module skeleton
# Created by Kamil Cukrowski (C) 2017. Under MIT License

# module using global variable name #######################

skel_init() {
	declare -g -a "$1=( [0]=0 )"
}
skel_add() {
	declare -g -a "$1=( [0]=$(($1[0]+$2)) )"
}
skel_getValue() {
	eval "echo \${$1[0]}"
}
skel_destroy() {
	unset $1
}

echo "module using global variable name"
skel_init myskel
skel_add myskel 2
skel_getValue myskel
skel_add myskel 5
skel_getValue myskel
skel_destroy myskel

# module using local variable name #####################

skel_init() {
	local skel
	skel[0]=0
	declare -p skel
}
skel_priv_load() {
	eval "\$$1"
}
skel_priv_save() {
	declare -p skel
}
skel_add() {
	local skel
	eval "\$$1"
	skel[0]=$((skel[0]+$2))
	declare -p skel
}
skel_getValue() {
	local skel
	eval "\$$1"
	echo ${skel[0]}
}
skel_destroy() {
	echo -n;
}

echo "module using local variable name"
myskel=$(skel_init)
myskel=$(skel_add myskel 2)
skel_getValue myskel
myskel=$(skel_add myskel 5)
skel_getValue myskel
myskel=$(skel_destroy myskel)

# module using local variable pointer name better #######################

skel_priv_echo() {
	echo "$(declare -p -- $@|tr '\n' ';')"
}
skel_priv_init() {
	local _skel_vars
	_skel_vars=(_skel_vars "$@")
	skel_priv_echo "${_skel_vars[@]}"
}
skel_priv_load() {	
	eval echo "\"local _skel_glob=\\\"$1\\\";\$$1\""
}
skel_priv_save() {
	eval "${1:-$_skel_glob}=\"$(skel_priv_echo "${_skel_vars[@]}")\""
}
skel_priv_destroy() {
	eval unset "$1"
}

skel_init() {
	local skel
	skel[0]=${1:-0}
	skel_priv_init skel
}
skel_add() {
	eval "$(skel_priv_load "$1")"
	skel[0]=$((skel[0]+$2))
	skel_priv_save
}
skel_getValue() {
	eval "$(skel_priv_load "$1")"
	echo ${skel[0]}
	skel_priv_save
}
skel_destroy() {
	skel_priv_destroy "$1"
}

echo "module using local variable pointer name better"
myskel=$(skel_init)
skel_add myskel 2
skel_getValue myskel
skel_add myskel 5
skel_getValue myskel
skel_destroy myskel

# module using filename ###################################

skel_init() { 
	local state skel
	skel[0]=0
	state=$(mktemp)
	declare -p skel > $state
	echo $state
}
skel_priv_load() {
	. $1
}
skel_priv_save() {
	declare -p skel > $1
}
skel_add() {
	. $1
	skel[0]=$((skel[0]+$2))
	declare -p skel > $1
}
skel_getValue() {
	. $1
	echo ${skel[0]}
	declare -p skel > $1
}
skel_destroy() {
	rm $1
}

echo "module using filename"
myskel=$(skel_init myskel)
skel_add $myskel 2
skel_getValue $myskel
skel_add $myskel 5
skel_getValue $myskel
skel_destroy $myskel

# module using file descriptor ############################

skel_init() {
	local skel
	skel[0]=0
	eval "exec $1<><(sleep infinity)"
	declare -p skel >&$1
}
skel_add() {
	$(head -n1 <&$1)
	skel[0]=$((skel[0]+$2))
	declare -p skel >&$1
}
skel_getValue() {
	$(head -n1 <&$1)
	echo ${skel[0]}
	declare -p skel >&$1
}
skel_destroy() {
	eval "exec $1<&-"
}

echo "module using file descriptor"
skel_init 5
skel_add 5 2
skel_getValue 5
skel_add 5 5
skel_getValue 5
skel_destroy 5

# module using file descriptor better ############################

skel_priv_init() {
	eval "exec $1<><(sleep infinity)"
	local _skel_vars _skel_glob
	_skel_glob="$1"
	shift
	_skel_vars=(_skel_glob _skel_vars "$@")
	skel_priv_save
}
skel_priv_save() {
	echo "$(declare -p -- ${_skel_vars[@]} | tr '\n' ';')" >&$_skel_glob
}
skel_priv_load() {
	head -n1 <&$1
}
skel_priv_destroy() {
	eval "exec $1<&-"
}
skel_init() {
	local skel
	skel[0]=0
	skel_priv_init "$1" skel
}
skel_add() {
	eval $(skel_priv_load "$1")
	skel[0]=$((skel[0]+$2))
	skel_priv_save
}
skel_getValue() {
	eval $(skel_priv_load "$1")
	echo ${skel[0]}
	skel_priv_save
}
skel_destroy() {
	skel_priv_destroy "$1"
}

echo "module using file descriptor better "
skel_init 5
skel_add 5 2
skel_getValue 5
skel_add 5 5
skel_getValue 5
skel_destroy 5

# eof ######################################################
#echo ${skel[0]}
