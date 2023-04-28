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














#Напишите скрипт, который принимает на вход директорию, как аргумент скрипту
#С помощью команды stat получает дату создания файлов в этой директории
#и добавляет ее в качестве префикса к файлу. Если в названии файла есть дата создания, файл должен пропускаться
# 
#Пример:
#Есть файл File, который создан 21-10-22
#Его необходимо автоматически переименовать в 21-10-22-File
#Фромат даты не важен
# 
#Примечание:
#Для вывода нужной строки, вы можете воспользоваться grep, и вывести нужное поле с помощью awk
#Вы можете передавать вывод команды на вход другой с помощью вертикальной черты.
#например ( cat /etc/passwd |grep root )
#
#В ответ прикрепить ТЕКСТОВЫЙ ФАЙЛ со скриптом.
#и скрин результата работы скрипта после нескольких запусков одной и той же директории
# ---- 		stat 
# ----		%
#
#stat --format %w . | awk '{print $1}'
