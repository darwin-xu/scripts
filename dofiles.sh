#!/bin/bash

# This script used to move media files into sorted folders.
# $1 The source folder to search
# $2 The destination folder to move to
# $3 The filter

scriptPath=`dirname $0`

dry=false
live=false

for var in "$@"
do
	if [[ $var"x" = "-hx" ]]; then
		echo "$0 <source_folder> <dest_folder> [filter] [-dry] [-live]"
		echo "Example: "
		echo "dofiles.sh /Volumes/Vault/photo/2015 /Volumes/Vault/video \".*mov|.*mp4\" -dry"
		exit 0
	elif [[ $var"x" = "-dryx" ]]; then
		dry=true
	elif [[ $var"x" = "-livex" ]]; then
		live=true
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

	extraArgs=()
	if [[ $live = true ]]; then
		extraArgs+=(-live)
	fi

	if [[ $filter"x" != "x" ]]; then
		find -E "$sour" -regex $filter -type f -exec "$scriptPath/moveFileToDateFolder.sh" {} "$dest" "$dry" "${extraArgs[@]}" \;
	else
		find "$sour" -type f -exec "$scriptPath/moveFileToDateFolder.sh" {} "$dest" "$dry" "${extraArgs[@]}" \;
	fi
fi
