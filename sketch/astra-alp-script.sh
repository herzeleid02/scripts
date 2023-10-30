#!/bin/bash

options=""

main

function main(){
	check_privileges
}

function check_privileges() {
	if [[ "$EUID" -ne 0 ]]
  		then echo "Please run as root"
  	exit 1;
	fi
}

function builder() {
	live-build-astra "$options" -r \
"https://download.astralinux.ru/astra/stable/1.7_x86-64/repository-main; \
https://download.astralinux.ru/astra/stable/1.7_x86-64/repository-update; \
https://download.astralinux.ru/astra/stable/1.7_x86-64/repository-base; \
https://download.astralinux.ru/astra/stable/1.7_x86-64/repository-extended"


}
