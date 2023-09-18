#!/bin/bash
gputype="" #var for gpu type (intel, amd, nvidia, other, optimus, intelamd)

function main() {
	gpuprobe
}

function check_distro() {
echo ""
}

function check_privileges() {
	if [[ "$EUID" -ne 0 ]]
  		then echo "Please run as root"
  	exit 1;
	fi
	
}

function flathub() {
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

function rpmfusion() {
	dnf upgrade --refresh -y
	dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
	dnf groupupdate core -y
}


function codecs_ffmpeg() {
	#universal operation
	dnf swap ffmpeg-free ffmpeg --allowerasing -y
	dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y
	dnf groupupdate sound-and-video
}

function gpuprobe() {
	gpus=$(lspci -vmm | grep -A1  "VGA compatible controller" | grep -v "^Class:" | cut -d ':' -f 2-  | tr -d '\t' | grep -v "^--" | cut -d ' ' -f 1 | tr '[:upper:]' '[:lower:]' | sort -u | tr -d '\n')
	echo "$gpus" #debug

	case $gpus in 
		"nvidia")
			echo "nvidia" #debug
			nvidiadrivers
			;;
		"intel")
			echo "intel" #debug
			codecs_intel
			;;
		"advanced")
			echo "amd" #debug
			codecs_amd
			;;
		"intelnvidia")
			echo "intelnvidia (optimus)" #debug
			optimus
			;;
		"advancednvidia")
			echo "advancednvidia (optimus)" #debug
			optimus
			;;
		"advancedintel")
			echo "amogus laptop" #debug
			#codecs_intel
			#codecs_amd
			codecs_sneed
			;;
		"*")
			echo "sneed gpu" #debug
		esac


}

function nvidiadrivers() {
	dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda nvidia-settings nvidia-vaapi-driver
	# pulled from rpm fusion page
}

function codecs_intel(){
	dnf install intel-media-driver
}

function codecs_amd(){
	dnf swap mesa-va-drivers mesa-va-drivers-freeworld
	dnf swap mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
	dnf swap mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
	dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld	
}

function intel_optimus(){
	echo "WIP"
}

function amd_optimus(){
	echo "WIP"
}

function codecs_sneed(){
	echo "sneed gpu"
}


function ascii() {
	#cat << EOF
	#EOF
	echo ""
}

main
