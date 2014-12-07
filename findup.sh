#!/bin/bash

# $1 the directory to find
#   --clean   clean the md5 value and exit.
#   --noscan  do not scan, use last md5 value.

function generateMd5 {
	totalFile=`find $1 -type f | wc -l | awk '{print $1}'`
	selfName=`basename $0`
	echo "${totalFile} 0" > "$tmpFilename"

	# Get the path of the script.
	scriptPath=`dirname $0`

	# Calculate the md5 of files
	echo "1) Calculate the md5 of files..."
	find "$1" -type f -exec $scriptPath/md5file.sh "$1" {} .md5 "$tmpFilename" \;
}

function processMd5 {
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
	totalLine=`cat .md5tablesort | wc -l |awk '{print $1}'`

	# Print duplicate files
	echo "4) Print duplicate files..."
	cur=0
	totalSize=0
	while read line; do
		# Update current progress
		cur=$((cur+1))
		printf "[$(printf %3d $((cur*100/totalLine)))%%]\r"

		# Get the md5 value
		md5v=`echo $line | awk -F\; '{print $1}'`
		file=`echo $line | awk -F\; '{print $2}'`

		# Print out the duplicated file
		if [ "$lastMd5v"x = "$md5v"x ]; then
			echo
			echo "Find dup file : [$lastFile] <-> [$file]"
			echo "rm \"$lastFile\"" >> rmfilelist
			rmSize=`stat -f "%z" "$lastFile"`
			totalSize=$((totalSize+rmSize))
		fi

		# Save for the last
		lastMd5v=$md5v
		lastFile=$file
	done < .md5tablesort

	echo
	echo "5) Please check file : rmfilelist"
	echo "Total size of dup files : $(printf %\'d $totalSize) bytes"
}

# Check if the `pwd` starts with $1, this means it can cause recursive scan and leads to infinate loop.
if [[ `pwd` == $1* ]]; then
	echo "NOTICE: Do not search the directory contains current directory!!!"
	exit
fi

if [ "$1"x = "--clean"x ]; then
	rm -rf .md5
	rm -f .md5table
	rm -f .md5tablesort
	rm -f rmfilelist
	exit
fi

tmpFilename=`echo "/tmp/${selfName}.$$.tmp"`

if [ "$1"x = "--noscan"x ]; then
	echo "1) Calculate the md5 of files... (skipped)"
else
	generateMd5 $1
	echo
fi

processMd5

rm -f "$tmpFilename"
