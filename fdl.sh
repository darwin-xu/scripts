#!/bin/bash

# $1 URL of the download file.

# Use '/' as the separator, print the last part of the URL, it should be the file name.
fileName=`echo $1 | awk -F/ '{print $NF}'`

# Get the file size by send request.
dlSize=`curl -sI $1 | grep Content-Length | awk -F '[ \r]' '{print $2}'`

# Call splitdl.sh
scriptPath=`dirname $0`
$scriptPath/splitdl.sh 0 $dlSize $1 "$fileName" .$$
