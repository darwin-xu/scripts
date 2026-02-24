#!/bin/bash

# --- timing start ---
__START_TS_EPOCH__=$(date +%s)
__START_HUMAN__=$(date '+%Y-%m-%d %H:%M:%S')
echo "[START] $0 at ${__START_HUMAN__}"

finish() {
	local end_epoch end_human duration secs mins hours
	end_epoch=$(date +%s)
	end_human=$(date '+%Y-%m-%d %H:%M:%S')
	duration=$(( end_epoch - __START_TS_EPOCH__ ))
	hours=$(( duration / 3600 ))
	mins=$(( (duration % 3600) / 60 ))
	secs=$(( duration % 60 ))
	printf '[END]   %s at %s  (Duration: %02d:%02d:%02d)\n' "$0" "$end_human" "$hours" "$mins" "$secs"
}
trap finish EXIT
# --- timing end ---

# This script used to move media files into sorted folders.
# $1 The source folder to search
# $2 The destination folder to move to
# $3 The filter

scriptPath=`dirname $0`

dry=false

for var in "$@"
do
	if [[ $var"x" = "-hx" ]]; then
		echo "$0 <source_folder> <dest_folder> [filter] [-dry]"
		echo "Example: "
		echo "dofiles.sh /Volumes/Vault/photo/2015 /Volumes/Vault/video \".*mov|.*mp4\" -dry"
		exit 0
	elif [[ $var"x" = "-dryx" ]]; then
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
		find -E "$sour" -regex $filter -type f -exec "$scriptPath/moveFileToDateFolder.sh" {} "$dest" "$dry" \;
	else
		find "$sour" -type f -exec "$scriptPath/moveFileToDateFolder.sh" {} "$dest" "$dry" \;
	fi
fi
