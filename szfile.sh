#!/bin/bash

# Get the size of file.

# $1 Source file
# $2 File to save size
# $3 the tmp stores the following info:
#    total file number, current progress

# Read the data from tmp file.
tot=`cat $3 | awk '{print $1}'`
cur=`cat $3 | awk '{print $2}'`

# Update current progress.
cur=$((cur+1))
echo "$tot $cur" > "$3"

printf "[$(printf %3d $((cur*100/tot)))%%] stat $(printf %-.80s $1) ...\r"

# Get the file size
fileSize=`stat -f "%z" "$1"`

# Add it to the end of the file
echo "$fileSize;$1" >> $2
