#!/bin/bash

# Move the file to date folder
# $1 the file need to be move
# $2 the destination folder
# $3 is this the dry run

# Use what time stamp?
# If all the timestamp is the same, use it.
# Or if the timestamp is not the same, use the one with timezone.

dest=`exiftool "$1" | awk '
BEGIN {
	dateName[0] = "Create Date";
	dateName[1] = "Creation Date";
	dateName[2] = "Content Create Date";
	dateName[3] = "Date/Time Original";
	dateName[4] = "Modify Date";
	dateName[5] = "Media Create Date";
	dateName[6] = "Media Modify Date";
	dateName[7] = "Track Create Date";
	dateName[8] = "Track Modify Date";
}
{
	for (n in dateName) {
		if (match($0, dateName[n]) != 0) {
			gsub(/^[^:]+: */, "", $0);
			if (match($0, /\+/) != 0)
				date = $0;
			else
				if (length(date) == 0)
					date = $0;
		}
	}
}
END {
	if (length(date) != 0) 
	{
		year  = substr(date, 1, 4);
		month = substr(date, 6, 2);
		day   = substr(date, 9, 2);
		print "/"year"/"year"-"month"/"year"-"month"-"day;
	}
}'`

orig=`dirname "${1#$2}"`
if [[ ( $dest"x" != "x" ) && ( $dest"x" != $orig"x" ) ]]; then
	if [[ $3 = true ]]; then
		echo "dry: $1 -> $2/$dest"
	else
		mkdir -p "$2/$dest"
		mv -vn "$1" "$2/$dest"
	fi
fi
