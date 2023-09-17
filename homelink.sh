#/bin/bash
# a script to symlink all neccessary stuff (data folders from ~/ and more)
shopt -u nullglob dotglob
SOURCEDIR="$1"
TARGETDIR="$2"
FILESEXTRA=( .mozilla )
LNARGS="-svi"

function main() {

if [[ ! -d "${SOURCEDIR}" ]]; then
echo "please, supply at least the source directory"
	default_output
fi

FILES=( $(realpath $SOURCEDIR)/* $SOURCEDIR${FILESEXTRA[@]})


if [[ ! -d "${TARGETDIR}" ]]; then 
	if [[ "$TARGETDIR" = "" ]]; then
		question
	else
		echo "Target directory is not valid"
		exit 1
	fi
fi




#TARGETDIR=$(realpath $TARGETDIR) # self-explanatory
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
		ln $LNARGS $(printf %q "$file") $TARGETDIR/$(basename $file)
	done
}

main
#filelist
#echo "################"
#printf %q "${FILES[25]}"

