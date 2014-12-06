#!/bin/bash

fileName=`echo $1 | awk -F/ '{print $NF}'`

blocks="4"
if [ "$#" = 2 ]; then
	blocks=$2
fi

echo "Try to download $1..."
dlSize=`curl -sI $1 | grep Content-Length | awk -F '[ \r]' '{print $2}'`
echo "Total size is : $dlSize"
blockSize=$((dlSize / blocks))

for (( i = 0; i < blocks; i++ ))
do
	b=$(( i * blockSize ))
	e=$(( (i + 1) * blockSize - 1 ))
	if [ $i = $((blocks - 1)) ]; then
		e=$dlSize
	fi
	cmd="curl -s -r $b-$e $1 -o .$$_$(printf %04d $i).tmp"
	echo "$i: $cmd"
	$cmd &
done

for (( i = 0; i < blocks; i++ ))
do
	wait %$(( i + 1 ))
done

cat .$$_????.tmp > $fileName

rm .$$_????.tmp
