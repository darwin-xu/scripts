#!/bin/bash

# $1 download begin range
# $2 download end range
# $3 URL of download file
# $4 target file name
# $5 blocks number
# $6 the folder to store the tmp files

dlSize=$(( $2 - $1 + 1 ))
blSize=$(( dlSize / $5 ))

scriptPath=`dirname $0`
for (( i = 0; i < $5; i++ ))
do
	bPos=$(( i * blSize + $1 ))
	ePos=$(( (i + 1) * blSize + $1 - 1 ))
	if [ $i = $(( $5 - 1 )) ]; then
		ePos=$2
	fi

	# call trydl.sh in background.
	echo "split: $(printf %16d $bPos) - $(printf %16d $ePos)"
	$scriptPath/trydl.sh $bPos $ePos "$3" "$6/$$_$(printf %03d $i).tmp" "$6" &
	echo $! >> "$6/trydl_$$.pid"
done

for (( i = 0; i < $5; i++ ))
do
	wait %$(( i + 1 ))
done

echo "---"$4

cat $6/$$_???.tmp > "$4"

rm $6/$$_???.tmp
