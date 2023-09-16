#/bin/bash
# a script to symlink all neccessary stuff (data folders from ~/ and more)
SOURCEDIR="$1"
TARGETDIR="$2"
FILES=( $(ls $HOME) )
FILESEXTRA=( .mozilla )
LNARGS="-sv"


function question {
	read -p "Use ${PWD} as the target directory? [y\N]: " answer
	#echo "$(echo $answer | tr '[:upper:]' '[:lower:]')" #debug
	if [ "$(echo $answer | tr '[:upper:]' '[:lower:]')" != "y" ]; then
		exit 1
	else
		$TARGETDIR="$PWD"
	fi
}

function default_output {
	echo "Usage: homelink.sh <SOURCE> [TARGET]"
}

function filelist {
	printf '%s\n' "${FILES[@]}"
} # debug function

function symlink { 
	for file in "${FILES[@]}"
	do
		echo "ln $LNARGS $SOURCEDIR $TARGETDIR"
		echo "1"
	done
}

function addtoarray {
#	FILES+=(.mozilla)
	FILES=("${FILES}[@]}" "${FILESEXTRA}[@]}")
}

addtoarray
filelist

if [[ ! -d "${SOURCEDIR}" ]]; then
echo "please, supply at least the source directory"
default_output
exit 1
fi

if [[ ! -d "${TARGETDIR}" ]]; then
question
	else
exit 1
fi

