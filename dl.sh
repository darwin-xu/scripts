#!/bin/bash

# Use '/' as the separator, print the last part of the URL, it should be the file name.
fileName=`echo $1 | awk -F/ '{print $NF}'`

# Default download blocks is 4.
blocks="4"

# If parameters number is 2.
if [ "$#" = 2 ]; then
	blocks=$2
fi

echo "Try to download $1..."

# Get the file size from the http header "Content-Length", use whitespace and '\r' as the separator.
# '\r' must be removed unless it will cause error in the following calculation.
dlSize=`curl -sI $1 | grep Content-Length | awk -F '[ \r]' '{print $2}'`

echo "Total size is : $dlSize"
blockSize=$((dlSize / blocks))

scriptPath=`dirname $0`

rm -f .bkpid
for (( i = 0; i < blocks; i++ ))
do
	# Block begin position.
	b=$(( i * blockSize ))
	# Block end position.
	e=$(( (i + 1) * blockSize - 1 ))
	# If it is the last block, use the size as the block end position.
	if [ $i = $((blocks - 1)) ]; then
		e=$dlSize
	fi

	# Create a .{pid}_000n.tmp temporary file.
	#cmd="curl -s -r $b-$e $1 -o .$$_$(printf %04d $i).tmp"
	cmd="$scriptPath/safedl.sh $b $e $1 .$$_$(printf %04d $i).tmp"
	echo "$i: $cmd"
	$cmd &
	$! >> .bkpid
done

for (( i = 0; i < blocks; i++ ))
do
	wait %$(( i + 1 ))
done

cat .$$_????.tmp > $fileName

rm .$$_????.tmp
