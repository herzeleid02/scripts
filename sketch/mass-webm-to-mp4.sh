#/bin/bash

# a script to symlink all neccessary stuff (data folders from ~/ and more)
shopt -u nullglob dotglob
sourcedir="$1"
targetdir="$2"
source_files=( ) 

function main(){
	checker
	sourcedir="$(realpath "${sourcedir}")"
	collect_source_files
	echo "====="
	printf %q "$sourcedir"
	echo "====="
	printf '%s\n' "${source_files[@]}"
}

function checker() {
if [[ ! -d "${sourcedir}" ]]; then
echo "please, supply at least the source directory"
	echo "Usage: "$0" <SOURCE> [TARGET]"
	exit 1
fi


if [[ ! -d "${targetdir}" ]]; then 
	if [[ "$targetdir" = "" ]]; then
		question
	else
		echo "Target directory is not valid"
		exit 1
	fi
fi
}

function collect_source_files(){
	for file in ${sourcedir}
	do
		source_files+=("$(printf %q "$file")")
	done
}

function parse_target(){
	echo ""
}

function question {
	read -p "Use ${PWD} as the target directory? [y\N]: " answer
	if [ "$(echo $answer | tr '[:upper:]' '[:lower:]')" != "y" ]; then
		exit 1
	else
		targetdir="$PWD"
	echo ""

	fi
}


main
