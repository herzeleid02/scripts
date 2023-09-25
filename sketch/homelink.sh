#/bin/bash -x
# a script to symlink all neccessary stuff (data folders from ~/ and more)
shopt -u nullglob dotglob
sourcedir="$(realpath $1)"
targetdir="$2"
files=( ) 
files_extra=( .mozilla)
#filesEXTRA=( .mozilla)
lnargs="-svi"

function main(){
	checker
	collect_source_files
	collect_extra_files

	echo "================="
	echo "${files[@]}"
	echo "================="
	printf '%s\n' "${files[@]}"
}

function checker() {
if [[ ! -d "${sourcedir}" ]]; then
echo "please, supply at least the source directory"
	default_output
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
		#echo -n "$file" #debug
		#printf %q "$file" #debug
		#echo "$file" # debug
		files+=("$(printf %q "$file")")
	done
}

function collect_extra_files(){
	for file in "${files_extra}"
	do
		#echo "$file" #debug
		#printf %q "$sourcedir" "$file" # debug
		files+=($(printf %q ${sourcedir}/"$file"))
	done
		
}

function parse_target(){
	echo ""
}

function parse_extra(){
	echo ""
}



function question {
	read -p "Use ${PWD} as the target directory? [y\N]: " answer
	#echo "$(echo $answer | tr '[:upper:]' '[:lower:]')" #debug
	if [ "$(echo $answer | tr '[:upper:]' '[:lower:]')" != "y" ]; then
		exit 1
	else
	#	targetdir="$PWD"
	echo ""

	fi
}


function default_output {
	echo "Usage: homelink.sh <SOURCE> [TARGET]"
	exit 1
}


function symlink {
	echo ""
}

main
#filelist
#echo "################"
#printf %q "${files[25]}"

