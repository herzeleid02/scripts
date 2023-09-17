#!/bin/bash
gputype="" #var for gpu type (intel, amd, nvidia, other, optimus)

function main() {
}

function distrocheck(){
}

function rpmfusion() {
	sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
	sudo dnf groupupdate core -y
}

function gpudetect() {
}

function codecs() {
}

function nvidiadrivers() {
}
