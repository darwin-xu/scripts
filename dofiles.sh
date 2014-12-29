#!/bin/bash

# This script used to remove empty folders.
# $1 The source folder to search
# $2 The destination folder to move to
# $3 The filter

scriptPath=`dirname $0`

dry=false

for var in "$@"
do
	if [[ $var"x" = "-dryx" ]]; then
		dry=true
	elif [[ $sour"x" = "x" ]]; then
		sour=$var
	elif [[ $dest"x" = "x" ]]; then
		dest=$var
	elif [[ $filter"x" = "x" ]]; then
		filter=$var
	fi
done

if [[ $sour"x" != "x" ]]; then
	if [[ $dest"x" = "x" ]]; then
		dest=$sour
	fi

	if [[ $filter"x" != "x" ]]; then
		find -E $sour -iregex $filter -type f -exec $scriptPath/moveFileToDateFolder.sh {} "$dest" $dry \;
	else
		find $sour -type f -exec $scriptPath/moveFileToDateFolder.sh {} "$dest" $dry \;
	fi
fi
