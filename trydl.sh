#!/bin/bash

# $1 download begin range
# $2 download end range
# $3 URL of download file
# $4 target file name
# $5 the folder to store the tmp files

scriptPath=`dirname $0`
retry=false
while true; do
	fileSize=0;
	if [ -f "$4" ]; then
		fileSize=`stat -f "%z" "$4"`
	fi
	downSize=$(($2 - $1 + 1))
	if [[ ($fileSize == $downSize) ]]; then
		break
	fi

	if [[ ($retry == true && $downSize > 100000) ]]; then
		"$scriptPath/splitdl.sh" "$1" "$2" "$3" "$4" "$5"
	else
		if [ $retry == true ]; then
			echo "retry: $(printf %16 $1) - $(printf %16 $2)"
		fi
		curl -s -r $1-$2 "$3" -o "$4"
	fi
	retry=true
done
