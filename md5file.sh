#!/bin/bash

# md5file

# $1 prefix path            ---          photo
# $2 source file            ---          photo/2012/2012-05/2012-05-12/DSC02383.ARW
# $3 destination directory  --- /Volumes/photo

md5Path=$3${2#$1}.md5
md5Dir=`dirname "$md5Path"`

if [ "$2" -nt "$md5Path" ]; then
	mkdir -p "$md5Dir"
	md5Value=`md5 -q "$2" | awk '{print $1}'`
	echo "$md5Value;$2" >> "$md5Path"
fi
