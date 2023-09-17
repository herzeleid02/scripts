#!/bin/bash
gputype="" #var for gpu type (intel, amd, nvidia, other, optimus)

function main() {
	gpudetect
}

function distrocheck() {
echo ""
}

function rpmfusion() {
	sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
	sudo dnf groupupdate core -y
}

function gpudetect() {
	#todo -- awk filter because this is embarassing (or case)
	#$gpustring=$(lscpi | grep -i "vga")

	if [[ $(lspci | grep -i "vga" | grep -i "intel") -eq 0 ]]; then
		gputype="intel"
	fi

	if [[ $(lspci |  grep -i "vga" | grep -i "advanced") -eq 0 ]]; then
		gputype="amd"
	fi

	if [[ $(lspci | grep -i "vga" | grep -i "nvidia") -eq 0 ]]; then
		gputype="nvidia"
	fi

	if [[ "$(lspci | grep -i "vga" | grep -ie "nvidia" -ie "intel")" -eq 0 ]]; then
		gputype="optimus"
	fi
echo $gputype
}

function codecs() {
echo ""
}

function nvidiadrivers() {
echo ""
}
main
