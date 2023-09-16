#/bin/bash
# a script to symlink all neccessary stuff (data folders from ~/ and more)
shopt -u nullglob dotglob
SOURCEDIR="$1"
TARGETDIR="$2"
TARGETDIR="$(realpath $2)/"
FILESEXTRA=( .mozilla )
FILES=( $HOME/* $HOME/.mozilla )
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


function default_output {
	echo "Usage: homelink.sh <SOURCE> [TARGET]"
}


function filelist {
	printf %q "${FILES[@]}"
} # debug function

function symlink {
	for file in "${FILES[@]}"
	do
		echo "ln $LNARGS $(printf %q "$file") $TARGETDIR"
	done
}


#filelist
symlink
#echo "################"
#printf %q "${FILES[25]}"

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
