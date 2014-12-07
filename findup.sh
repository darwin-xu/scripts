#!/bin/bash

# $1 the directory to find

if [ "$1"x = "--clean"x ]; then
	rm -rf .md5
	rm -f .md5table
	rm -f .md5tablesort
	rm -f rmfilelist
	exit
fi

# Get the path of the script.
scriptPath=`dirname $0`

# Calculate the md5 of files
find "$1" -type f -exec $scriptPath/md5file.sh "$1" {} .md5 \;

# Remove the last file
if [ -f .md5table ]; then
	rm .md5table
fi

# Sum the md5 up.
find .md5 -type f -exec cat {} >> .md5table \;

# sort the file.
sort .md5table > .md5tablesort
rm .md5table

while read line; do
	# Get the md5 value
	md5v=`echo $line | awk -F\; '{print $1}'`
	file=`echo $line | awk -F\; '{print $2}'`

	# Print out the duplicated file
	if [ "$lastMd5v"x = "$md5v"x ]; then
		echo "Find dup file : [$lastFile] <-> [$file]"
		echo "rm $lastFile" >> rmfilelist
	fi

	# Save for the last
	lastMd5v=$md5v
	lastFile=$file
done < .md5tablesort
