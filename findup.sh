#!/bin/bash

# $1 the directory to find

rm -rf .md5

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

# echo "2) Collecting the file size information..."
# rm -f .szmap
# find $1 -type f -exec "$scriptPath/szfile.sh" {} ".szmap" "$tmpFilename" \;
# sort -n .szmap > .sortszmap
# rm -f .szmap
# rm "$tmpFilename"
# echo

echo "3) Calculate the md5 value..."
cur=0
lastSize=0
while read line; do
	cur=$((cur+1))
	printf "[$(printf %3d $((cur*100/totalFile)))%%]\r"

	size=`echo $line | awk -F\; '{print $1}'`
	file=`echo $line | awk -F\; '{print $2}'`

	if [[ ($lastSize == $size && $size > 100000) ]]; then
		echo
		echo "md5 $lastFile"
		echo "md5 $file"
		"$scriptPath/md5file.sh" "$1" "$lastFile" ".md5"
		"$scriptPath/md5file.sh" "$1" "$file" ".md5"
	fi

	lastSize=$size
	lastFile=$file
done < .sortszmap
echo

#rm -r .sortszmap

# Sum the md5 up
echo "4) Sum the md5 value up..."
rm -f .md5table
find .md5 -type f -exec cat {} >> .md5table \;

# Sort the md5 file
echo "5) Sort the md5 table file..."
sort .md5table > .md5tablesort
rm -f .md5table
totalLine=`cat .md5tablesort | wc -l |awk '{print $1}'`

# Print duplicate files
echo "6) Print duplicate files..."
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
		fileSize=`stat -f "%z" "$lastFile"`
		totalSize=$((totalSize+fileSize))
	fi

	# Save for the last
	lastMd5v=$md5v
	lastFile=$file
done < .md5tablesort

rm -f .md5tablesort

echo "Total size of dup files : $(printf %\'d $totalSize)B"
