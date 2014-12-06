#!/bin/bash

# safemv move the source file into directory safely,
# If the target file is exist, it will check if it is the same.
#   If it is the same, it will remove it.
#   If it is not the same, it will rename and move it.

# $1 source file
# $2 destination directory
dstPath=`dirname $1`
echo $dstPath
