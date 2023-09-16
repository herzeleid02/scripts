#/bin/bash
# a script to symlink all neccessary stuff (data folders from ~/ and more)
shopt -u nullglob dotglob
SOURCEDIR="$1"
TARGETDIR="$2"
FILESEXTRA=( .mozilla )
FILES=( $(realpath $SOURCEDIR)/* $SOURCEDIR${FILESEXTRA[@]})
LNARGS="-sv"

function main() {

if [[ ! -d "${SOURCEDIR}" ]]; then
echo "please, supply at least the source directory"
	default_output
fi

if [ ! -d "${TARGETDIR}" ]; then
	question
fi

TARGETDIR=$(realpath $TARGETDIR) # self-explanatory
symlink

}


function question {
	read -p "Use ${PWD} as the target directory? [y\N]: " answer
	#echo "$(echo $answer | tr '[:upper:]' '[:lower:]')" #debug
	if [ "$(echo $answer | tr '[:upper:]' '[:lower:]')" != "y" ]; then
		exit 1
	else
		TARGETDIR="$PWD"

	fi
}


function default_output {
	echo "Usage: homelink.sh <SOURCE> [TARGET]"
	exit 1
}


function symlink {
	for file in "${FILES[@]}"
	do
		echo "ln $LNARGS $(printf %q "$file") $TARGETDIR/$(basename $file)"
	done
}

main
#filelist
#echo "################"
#printf %q "${FILES[25]}"

