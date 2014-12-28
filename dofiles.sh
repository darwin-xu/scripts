#!/bin/bash

# This script used to remove empty folders.
# $1 The source folder to search
# $2 The destination folder to move to
# $3 The filter

scriptPath=`dirname $0`

if [[ $# -ge 2 ]]; then
	dest=$2
else
	dest=$1
fi

#find $1 -iname "$filter" -type f 

if [[ $3"x" != "x" ]]; then
	find -E $1 -iregex $3 -type f -exec $scriptPath/moveFileToDateFolder.sh {} "$dest" \;
else
	find $1 -type f -exec $scriptPath/moveFileToDateFolder.sh {} "$dest" \;
fi
