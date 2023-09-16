#/bin/bash
# a script to symlink all neccessary stuff (data folders from ~/ and more)
SOURCEDIR="$1"
TARGETDIR="$2"
FILESEXTRA=( .mozilla )
FILES=( $(ls -d $HOME/* $FILESEXTRA) ) # replace with sourcedir pls
LNARGS="-sv"

echo ${FILES[@]}

function question {
	read -p "Use ${PWD} as the target directory? [y\N]: " answer
	#echo "$(echo $answer | tr '[:upper:]' '[:lower:]')" #debug
	if [ "$(echo $answer | tr '[:upper:]' '[:lower:]')" != "y" ]; then
		exit 1
	else
		$TARGETDIR="$PWD"
	fi
}


function namehandler {
	FILES=( "${FILES[@]}" "${FILESEXTRA[@]}" )
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
		echo "ln $LNARGS $file $TARGETDIR"
	done
}


namehandler
filelist
symlink

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

