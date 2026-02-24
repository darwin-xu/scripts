#!/bin/bash

# Move the file to date folder
# $1 the file need to be moved
# $2 the destination folder
# $3 is this the dry run

sourceFile="$1"
destRoot="$2"
dry=${3:-false}

sourceDir=$(dirname "$sourceFile")
sourceFilename=`basename "$sourceFile"`
sourceBase=${sourceFilename%.*}
sourceExtLower=`printf '%s' "${sourceFilename##*.}" | tr '[:upper:]' '[:lower:]'`

# Use what time stamp?
# If all the timestamp is the same, use it.
# Or if the timestamp is not the same, use the one with timezone.

resolve_date_folder() {
	exiftool "$1" | grep Date | awk '
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
		if (int(n) < matchIndex && match($0, dateName[n]) == 1) {
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
}'
}

dest=`resolve_date_folder "$sourceFile"`

sourPath=$(echo "$sourceFile" | sed 's#//*#/#g')

liveTag=""

if [[ $sourceExtLower = "heic" ]]; then
	movCandidate="$sourceDir/$sourceBase.mov"
	movSource="$movCandidate"
	if [[ -f "$movCandidate" ]]; then
		heicDim=$(exiftool -s -s -s -ImageSize "$sourceFile" 2>/dev/null)
		movDim=$(exiftool -s -s -s -ImageSize "$movCandidate" 2>/dev/null)
		if [[ -n "$heicDim" && -n "$movDim" ]]; then
			IFS=x read -r heicW heicH <<< "$heicDim"
			IFS=x read -r movW movH <<< "$movDim"
			if [[ $heicW =~ ^[0-9]+$ && $heicH =~ ^[0-9]+$ && $movW =~ ^[0-9]+$ && $movH =~ ^[0-9]+$ ]]; then
				if (( heicW * movH == movW * heicH )); then
					movDuration=$(exiftool -n -s -s -s -Duration "$movCandidate" 2>/dev/null)
					if [[ $movDuration =~ ^[0-9]+([.][0-9]+)?$ ]]; then
						if awk -v d="$movDuration" 'BEGIN { exit !(d < 5) }'; then
							movDest=`resolve_date_folder "$movCandidate"`
							if [[ "$movDest" = "$dest" ]]; then
								liveTag=" (live)"
							else
								movSource=""
								echo "Warning: Skip moving $movCandidate; date folder does not match HEIC."
							fi
						else
							movSource=""
							echo "Warning: Skip moving $movCandidate; duration is ${movDuration}s (must be < 5s)."
						fi
					else
						movSource=""
						echo "Warning: Skip moving $movCandidate; invalid duration value '$movDuration'."
					fi
				else
					movSource=""
					echo "Warning: Skip moving $movCandidate; aspect ratio mismatch (HEIC:${heicW}x${heicH} MOV:${movW}x${movH})."
				fi
			else
				movSource=""
				echo "Warning: Skip moving $movCandidate; invalid dimensions (HEIC:'$heicDim' MOV:'$movDim')."
			fi
		else
			movSource=""
			echo "Warning: Skip moving $movCandidate; could not determine dimensions (HEIC:'$heicDim' MOV:'$movDim')."
		fi
	else
		movSource=""
	fi
fi

if [[ $dest"x" != "x" ]]; then
	# Get the filename from whole path
	filename="$sourceFilename"
	destPath=$(echo "$destRoot/$dest/$filename" | sed 's#//*#/#g')
	destDir=$(dirname "$destPath")

	# If the destination path is not the same, then move
	if [[ $sourPath != $destPath ]]; then

		if [[ $dry = true ]]; then
			echo "Dry: $sourPath -> $destPath$liveTag"
		else
			mkdir -p "$destDir"
			if [[ -f "$destPath" ]]; then
				a=`md5 -q "$sourPath"`
				b=`md5 -q "$destPath"`
				if [[ $a = $b ]]; then
					echo "Remove the duplicate file $sourPath"
					x=$sourPath bash -c 'rm "$x"'
				else
					echo "$sourPath is different than $destPath"
				fi
			else
				echo "$sourPath -> $destPath$liveTag"
				mv -n "$sourPath" "$destPath"
			fi
		fi
	else
		echo "Correct path, skip for: $sourPath"
	fi

	if [[ $sourceExtLower = "heic" && "$movSource" != "" ]]; then
		"$0" "$movSource" "$destRoot" "$dry"
	fi
else
	echo "Could not determine the path for $sourPath"
fi
