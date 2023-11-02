#!/bin/bash
sourcedir="~/Videos/webm funni"

function main(){
	parse
}

function parse(){
	for file in "$sourcedir"
	do
		printf %q file
	done
}
