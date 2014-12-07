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

# Check if the `pwd` starts with $1, this means it can cause recursive scan and leads to infinate loop.
if [[ `pwd` == $1* ]]; then
	echo "Do not search the directory contains current directory!!!"
	exit
fi

# Calculate the md5 of files
echo "1) Calculate the md5 of files..."
find "$1" -type f -exec $scriptPath/md5file.sh "$1" {} .md5 \;

# Remove the last file
if [ -f .md5table ]; then
	rm .md5table
fi

# Sum the md5 up
echo "2) Sum the md5 up..."
find .md5 -type f -exec cat {} >> .md5table \;

# Sort the md5 file
echo "3) Sort the md5 file..."
sort .md5table > .md5tablesort
rm .md5table

# Print duplicate files
echo "4) Print duplicate files..."
while read line; do
	# Get the md5 value
	md5v=`echo $line | awk -F\; '{print $1}'`
	file=`echo $line | awk -F\; '{print $2}'`

	# Print out the duplicated file
	if [ "$lastMd5v"x = "$md5v"x ]; then
		echo "Find dup file : [$lastFile] <-> [$file]"
		echo "rm \"$lastFile\"" >> rmfilelist
	fi

	# Save for the last
	lastMd5v=$md5v
	lastFile=$file
done < .md5tablesort

echo "5) Please check file : rmfilelist"
