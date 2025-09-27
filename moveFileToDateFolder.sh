#!/bin/bash

# Move the file to date folder
# $1 the file need to be moved
# $2 the destination folder
# $3 is this the dry run
# $4 optional -live flag

sourceFile="$1"
destRoot="$2"
dry=${3:-false}

live=false
if [[ ${4:-} = "-live" ]]; then
	live=true
elif [[ ${4:-} = "true" ]]; then
	live=true
fi

# Use what time stamp?
# If all the timestamp is the same, use it.
# Or if the timestamp is not the same, use the one with timezone.

dest=`exiftool "$sourceFile" | grep Date | awk '
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
}'`

sourPath=$(echo "$sourceFile" | sed 's#//*#/#g')

if [[ $dest"x" != "x" ]]; then
	# Get the filename from whole path
	filename=`basename "$sourceFile"`
	destPath=$(echo "$destRoot/$dest/$filename" | sed 's#//*#/#g')
	destDir=$(dirname "$destPath")

	if [[ $live = true ]]; then
		baseName=${filename%.*}
		baseNameLower=`printf '%s' "$baseName" | tr '[:upper:]' '[:lower:]'`
		imageFound=false
		matchedImage=""
		if [[ -d "$destDir" ]]; then
			while IFS= read -r imageFile; do
				imageFilename=`basename "$imageFile"`
				imageBase=${imageFilename%.*}
				imageBaseLower=`printf '%s' "$imageBase" | tr '[:upper:]' '[:lower:]'`
				if [[ "$imageBaseLower" = "$baseNameLower" ]]; then
					imageFound=true
					matchedImage="$imageFile"
					break
				fi
			done < <(find "$destDir" -maxdepth 1 -type f \( -iname "*.heic" -o -iname "*.jpg" -o -iname "*.jpeg" \))
		fi

		if [[ $imageFound = false ]]; then
			echo "Warning: Skip moving $sourPath; no corresponding image found in $destDir."
			exit 0
		fi

		# Aspect ratio check: ensure source file and matched image share same aspect ratio
		srcDim=$(exiftool -s -s -s -ImageSize "$sourPath" 2>/dev/null)
		imgDim=$(exiftool -s -s -s -ImageSize "$matchedImage" 2>/dev/null)
		if [[ -z "$srcDim" || -z "$imgDim" ]]; then
			echo "Warning: Skip moving $sourPath; could not determine dimensions (src:'$srcDim' img:'$imgDim')."
			exit 0
		fi
		IFS=x read -r srcW srcH <<< "$srcDim"
		IFS=x read -r imgW imgH <<< "$imgDim"
		# Validate numeric
		if ! [[ $srcW =~ ^[0-9]+$ && $srcH =~ ^[0-9]+$ && $imgW =~ ^[0-9]+$ && $imgH =~ ^[0-9]+$ ]]; then
			echo "Warning: Skip moving $sourPath; invalid dimension values (src:$srcDim img:$imgDim)."
			exit 0
		fi
		# Compare aspect ratios via cross multiplication to avoid floating point
		if (( srcW * imgH != imgW * srcH )); then
			echo "Warning: Skip moving $sourPath; aspect ratio mismatch (src:${srcW}x${srcH} vs img:${imgW}x${imgH})."
			exit 0
		fi
	fi

	# If the destination path is not the same, then move
	if [[ $sourPath != $destPath ]]; then

		if [[ $dry = true ]]; then
			echo "Dry: $sourPath -> $destPath"
		else
			mkdir -p "$destDir"
			if [[ -f "$destPath" ]]; then
				a=`md5 -q "$sourPath"`
				b=`md5 -q "$destPath"`
				if [[ $a = $b ]]; then
					echo "Remove the duplicate file $sourPath"
					x=$sourPath bash -c 'rm -v "$x"'
				else
					echo "$sourPath is different than $destPath"
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
