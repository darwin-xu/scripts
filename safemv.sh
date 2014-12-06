#!/bin/bash

# safemv move the source file into directory safely,
# If the target file is exist, it will check if it is the same.
#   If it is the same, it will remove it.
#   If it is not the same, it will rename and move it.

# $1 prefix path            ---          photo
# $2 source file            ---          photo/2012/2012-05/2012-05-12/DSC02383.ARW
# $3 destination directory  --- /Volumes/photo

dstPath=$3${2#$1}
dstDir=`dirname $dstPath`

if [ -f $dstPath ]; then
	# Target file exist, check it if is the same.
	srcMd5=`md5 -q $2`
	dstMd5=`md5 -q $dstPath`

	if [ "$srcMd5"x = "$dstMd5"x ]; then
		# Source and target is the same, remove source.
		echo "Remove identical file: $2"
		rm -f $2
	else
		# Source and target is different, rename
		moved=false
		for i in {1..100}
		do
			if [ ! -f "${dstPath}_${i}" ]; then
				echo "File with same name exist, rename to: ${dstPath}_${i}"
				mv $2 ${dstPath}_${i}
				moved=true
				break
			fi
		done
		if [ $moved = false ]; then
			echo "Failed to move file:$2"
		fi
	fi
else
	# Target file doesn't exist, move to.
	echo "Move file to: $dstPath"
	mkdir -p $dstDir
	mv $2 $dstDir
fi
