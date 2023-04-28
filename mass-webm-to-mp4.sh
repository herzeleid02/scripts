# DO NOT USE IT
# probably need to redo this shit lol with uhhh file handling

#!/bin/bash

if [ -z $1 ] || [ ! -d $1 ];
	then
	echo "Usage: [input dir] [output dir]"
	exit 1
fi

input_dir=$1
output_dir=$2

echo $input_dir
echo $output_dir


for i in "$input_dir"/*.webm; do ffmpeg -n -i "$i" ""$output_dir"/${i%.*}.mp4"; done
exit 0
