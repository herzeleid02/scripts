#!/bin/bash

shopt -s nullglob
#shopt -s dotglob # support for dotfiles (starting with .)

if [ -z $1 ] || [ ! -d $1 ];
	then
	echo "Please supply a valid directory with readable files"
	exit 1
fi

workdir=$(realpath $1)/
#echo $workdir

for oldname in $workdir*; 
do
	crdate=$(stat -c %w $oldname | awk '{print $1}')
	oldname=$(basename $oldname)
	newname="$crdate-$oldname"
	mv -v $workdir$oldname $workdir$newname
done
exit 0

	


# addendum
#crdate=$(stat -c %y $oldname | awk '{print $1}')
