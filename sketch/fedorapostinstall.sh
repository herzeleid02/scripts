#!/bin/bash
gputype="" #var for gpu type (intel, amd, nvidia, other, optimus)

function main() {
	gpuprobea
}

function distrocheck() {
echo ""
}

function rpmfusion() {
	sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
	sudo dnf groupupdate core -y
}

function gpuprobeb(){
	#function for checking if it has dual-gpu srtup (optimus)
echo ""
}

function gpuprobea() {
	gpustring=$(lspci | grep -i "VGA" | cut -c 36-38)
	echo "$gpustring"

	case $(lspci | grep -i "VGA" | tr '[:upper:]' '[:lower:]' | cut -c 36-38) in
		"nvi")
			echo "Nvidia"
			gputype="nvidia"
			;;
		"adv")
			echo "AMD Radeon"
			gputype="amd"
			;;
		"int")
			echo "Intel"
			gputype="intel"
			;;
	esac
}

function codecs() {
echo ""
}

function nvidiadrivers() {
echo ""
}

function ascii() {
	#cat << EOF
	#EOF
	echo ""
}

main
