#!/bin/bash

# $1 the directory to find

rm -rf .md5
rm -f dupfilelist

# Check if the `pwd` starts with $1, this means it can cause recursive scan and leads to infinate loop.
if [[ `pwd` == $1* ]]; then
	echo "NOTICE: Do not search the directory contains current directory!!!"
	exit
fi

selfName=`basename $0`
tmpFilename=`echo "/tmp/${selfName}.$$.tmp"`
scriptPath=`dirname $0`

echo "1) Prepare the directory..."
totalFile=`find $1 -type f | wc -l | awk '{print $1}'`
echo "${totalFile} 0" > "$tmpFilename"

echo "2) Collecting the file size information..."
rm -f .szmap
find $1 -type f -exec "$scriptPath/szfile.sh" {} ".szmap" "$tmpFilename" \;
sort -n .szmap > .sortszmap
rm -f .szmap
rm "$tmpFilename"
echo

echo "3) diff on same size files..."
cur=0
lastSize=0
totalSize=0
while read line; do
	cur=$((cur+1))
	printf "[$(printf %3d $((cur*100/totalFile)))%%]\r"

	size=`echo $line | awk -F\; '{print $1}'`
	file=`echo $line | awk -F\; '{print $2}'`

	if [[ ($lastSize == $size && $size > 100000) ]]; then

		diff -q "$lastFile" "$file"

		if [[ $? == 0 ]]; then
			echo "Find dup file : [$lastFile] <-> [$file]" >> dupfilelist
			fileSize=`stat -f "%z" "$lastFile"`
			totalSize=$((totalSize+fileSize))
		fi
	fi

	lastSize=$size
	lastFile=$file
done < .sortszmap
echo

rm .sortszmap

echo "Total size of dup files : $(printf %\'d $totalSize)B"
