#/bin/bash -x

# a script to symlink all neccessary stuff (data folders from ~/ and more)
shopt -u nullglob dotglob
sourcedir="$1"
targetdir="$2"
files=( ) 
links=( )
files_extra=( .mozilla .chromium )
#filesEXTRA=( .mozilla)
lnargs="-svi"

function main(){
	checker
	sourcedir="$(realpath "$sourcedir")"
	collect_source_files
	collect_extra_files
	parse_target
	symlink
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
	for file in ${sourcedir}/*
	do
		files+=("$(printf %q "$file")")
	done
}

function collect_extra_files(){
	for file in "${files_extra[@]}"
	do
		files+=($(printf %q ${sourcedir}/"$file"))
	done
		
}

function parse_target(){
	targetdir="$(realpath "$targetdir")"	
	for file in "${files[@]}"
	do
		links+=("$targetdir"/$(basename "$file"))
	done
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

function symlink {
	for filenamecount in ${!files[@]}
	do
		ln "$lnargs" "${files[filenamecount]}" "${links[filenamecount]}"
	done
}

main
