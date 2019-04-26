#!/bin/bash

# $1 the source directory
# $2 the destination directory

# Get the path of the script.
scriptPath=`dirname $0`

find $1 -type f -exec $scriptPath/safemv.sh $1 {} $2 \;
