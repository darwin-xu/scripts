#!/bin/bash

# $1 URL of the download file.

# Use '/' as the separator, print the last part of the URL, it should be the file name.
fileName=`echo $1 | awk -F/ '{print $NF}'`

# Get the file size by send request.
dlSize=`curl -sI $1 | grep Content-Length | awk -F '[ \r]' '{print $2}'`

# Call splitdl.sh
scriptPath=`dirname $0`
mkdir $$
$scriptPath/splitdl.sh 0 $((dlSize - 1)) $1 "$fileName" 30 $$ &

while [[ ! -f fileName ]]; do
	curSize=`ls -l $$/*.tmp | awk '{t+=$5} END {print t}'`
	printf "[$(printf %3d $((curSize*100/dlSize)))%%]\r"
	sleep 1
done
