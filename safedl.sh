#!/bin/bash

# $1 begin range
# $2 end range
# $3 download address
# $4 output file


cmd="curl -s -r $1-$2 $3 -o $4"
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
	if [ $retry == true ]; then
		echo "retry: "$cmd
	fi
	$cmd
	retry=true
done
