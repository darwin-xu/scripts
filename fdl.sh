#!/bin/bash

# $1 URL of the download file.

curlResult=`curl -sI "$1" | awk '
/Content-Length/ {sub(/Content-Length:[[:space:]]*/, ""); split($0, b, /\r/); dSize = b[1]}
/Content-Disposition/ {sub(/Content-Disposition:/, ""); n = split($0, a, /;|\r/);
	for (i = 1; i <= n; i++) {
		if (match(a[i], /filename=/))
			{fname=sub(/filename=/,"",a[i]);
			fName=a[i]}
	}
}
END {
	print dSize, fName
}'`

dlSize=`echo $curlResult | awk '{print $1}'`
fileName=`echo $curlResult | awk '{print $2}'`

# Use '/' as the separator, print the last part of the URL, it should be the file name.
if [[ "$fileName"x = ""x ]]; then
	fileName=`echo $1 | awk -F/ '{print $NF}'`
fi

# # Get the file size by send request.
# dlSize=`curl -sI "$1" | grep Content-Length | awk -F '[ \r]' '{print $2}'`

# Call splitdl.sh
scriptPath=`dirname $0`
mkdir $$
$scriptPath/splitdl.sh 0 $((dlSize - 1)) "$1" "$fileName" 30 $$ &

while [[ ! -f $fileName ]]; do
	curSize=`ls -l $$/*.tmp | awk '{t+=$5} END {print t}'`
	printf "[$(printf %3d $((curSize*100/dlSize)))%%]\r"
	sleep 1
done
