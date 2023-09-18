#!/bin/bash
gputype="" #var for gpu type (intel, amd, nvidia, other, optimus, intelamd)
#gpuamount=$(cat ./fakelspci | grep -ice "VGA")  #debug
gpuamount=$(lspci | grep -ice "VGA")

function main() {
	gpuprobeb
	gpuprobea
}

function distrocheck() {
echo ""
}

function rpmfusion() {
	sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
	sudo dnf groupupdate core -y
}

function gpuprobec() {
	# function for checking for amd+amd setups or intel+amd or intel+nvidia
	# invoke only in case when u have 2 cards
		
}



function gpucount() {
	#function for counting gpus
	echo $gpuamount #debug
	case $gpuamount in
		"0")
			echo "amogus -- no gpu" #debug
			;;
		"1")
			echo "one gpu" # debug
			#gpuprobea
			;;
		"2")
			echo "two gpu" # debug
			#gpuprobec
			;;
		*)
			echo "AMOGUS" #debug
			;;
	esac

}

function gpuprobea() {
	#function for checking single gpu
	gpustring=$(lspci | grep -i "VGA" | cut -c 36-38)
	echo "$gpustring" #debug

	case $(lspci | grep -i "VGA" | tr '[:upper:]' '[:lower:]' | cut -c 36-38) in
		"nvi")
			echo "Nvidia" #debug
			gputype="nvidia"
			;;
		"adv")
			echo "AMD Radeon" #debug
			gputype="amd"
			;;
		"int")
			echo "Intel" #debug
			gputype="intel"
			;;
		"*")
			echo "AMOGUS GPU" # debug
			gputype="other"
			;;
	esac
}

function gpubprobeb()
	# function for dualgpu installs, dont invoke it when the gpu is 1
	if 

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
