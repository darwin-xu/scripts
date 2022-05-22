#!/bin/bash

# Move the file to date folder
# $1 the file need to be moved
# $2 the destination folder
# $3 is this the dry run

# Use what time stamp?
# If all the timestamp is the same, use it.
# Or if the timestamp is not the same, use the one with timezone.

dest=`exiftool "$1" | awk '
BEGIN {
	# The name for search the date in file.
	# Index means priority, the lower the index is, the higher the priority is
	dateName[0] = "Date/Time Original";
	dateName[1] = "Creation Date";
	dateName[2] = "Create Date";
	dateName[3] = "Content Create Date";
	dateName[4] = "Modify Date";
	dateName[5] = "Media Create Date";
	dateName[6] = "Media Modify Date";
	dateName[7] = "Track Create Date";
	dateName[8] = "Track Modify Date";
	dateName[9] = "File Inode Change Date/Time";
	matchIndex = 10;
}
{
	for (n in dateName) {
		# If find the "date" in exif info and its priority higher than before match
		if (int(n) < matchIndex && match($0, dateName[n]) != 0) {
			# Remove the leading part
			gsub(/^[^:]+: */, "", $0);
			year  = substr($0, 1, 4);
			month = substr($0, 6, 2);
			day   = substr($0, 9, 2);
			if (!match(year, "0000") && !match(month, "00") && !match(day, "00")) {
				date = $0;
				matchIndex = n;
			}
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

sourPath=$(echo $1 | sed s#//*#/#g)

if [[ $dest"x" != "x" ]]; then
	# Get the filename from whole path
	filename=`basename "$1"`

	# Compose the destination path and remove the extra slash
	destPath=$(echo $2/$dest/$filename | sed s#//*#/#g)

	# If the destination path is not the same, then move
	if [[ $sourPath != $destPath ]]; then

		if [[ $3 = true ]]; then
			echo "Dry: $sourPath -> $destPath"
		else
			mkdir -p `dirname $destPath`
			if [[ -f "$destPath" ]]; then
				a=`md5 -q "$sourPath"`
				b=`md5 -q "$destPath"`
				if [[ $a = $b ]]; then
					#bash -c 'echo "$sourPath"'
					x=$sourPath bash -c 'rm -v "$x"'
				else
					echo "$sourPath is different"
				fi
			else
				mv -vn "$sourPath" "$destPath"
			fi
		fi
	else
		echo "Correct path, skip for: $sourPath"
	fi
else
	echo "Could not determine the path for $sourPath"
fi
