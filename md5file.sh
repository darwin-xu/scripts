#!/bin/bash

# md5file

# $1 prefix path            ---          photo
# $2 source file            ---          photo/2012/2012-05/2012-05-12/DSC02383.ARW
# $3 destination directory  --- /Volumes/photo

# Get the filename to store the md5 value.
md5Path=$3${2#$1}.md5
md5Dir=`dirname "$md5Path"`

# Update the md5 value if the file is newer than the .md5 file.
if [ "$2" -nt "$md5Path" ]; then
	printf "md5 $2 ... \r"
	mkdir -p "$md5Dir"
	md5Value=`md5 -q "$2" | awk '{print $1}'`
	echo "$md5Value;$2" >> "$md5Path"
fi
