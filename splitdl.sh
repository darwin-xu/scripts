#!/bin/bash

# $1 download begin range
# $2 download end range
# $3 URL of download file
# $4 target file name
# $5 the folder to store the tmp files

# No more than 99
blocks=10

dlSize=$(( $2 - $1 + 1 ))
blSize=$(( dlSize / block ))

scriptPath=`dirname $0`
for (( i = 0; i < blocks; i++ ))
do
	bPos=$(( i * blSize ))
	ePos=$(( (i + 1) * blSize - 1 ))
	if [ $i = $(( blocks - 1 )) ]; then
		ePos=$blSize
	fi

	# call trydl in background.
	echo "split: $(printf %16 $bPos) - $(printf %16 $ePos)"
	$scriptPath/trydl.sh $bPos $ePos "$3" "$5/$$_$(printf %03d $i).tmp" &
	echo $! >> "$5/trydl_$$.pid"
done

for (( i = 0; i < blocks; i++ ))
do
	wait %$(( i + 1 ))
done

cat "$5/$$_???.tmp" > "$4"

rm "$5/$$_???.tmp"
