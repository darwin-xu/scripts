#!/bin/bash

# $1 download begin range
# $2 download end range
# $3 URL of download file
# $4 target file name
# $5 the folder to store the tmp files

touch $$.pid

scriptPath=`dirname $0`
retryTime=0
downSize=$(($2 - $1 + 1))
while [[ $retryTime -lt 10 ]]; do
	fileSize=0;
	if [ -f "$4" ]; then
		fileSize=`stat -f "%z" "$4"`
	fi
	if [[ $fileSize -eq $downSize ]]; then
		break
	else
		rm -f $4
	fi

	processNumber=`find . -name "*.pid" | wc -l | awk '{print $0}'`

	if [[ ($retryTime -ne 0 && $processNumber < 50) ]]; then
		"$scriptPath/splitdl.sh" "$1" "$2" "$3" "$4" 2 "$5"
	else
		curl -Y 1000 -y 10 -s -r $1-$2 "$3" -o "$4"
	fi
	retryTime=$((retryTime + 1))
	sleep 1
done

rm $$.pid

fileSize=0
if [ -f "$4" ]; then
	fileSize=`stat -f "%z" "$4"`
fi

if [[ $fileSize -eq $downSize ]]; then
	# 0 for success
	exit 0
else
	# 1 for error
	exit 1
fi
