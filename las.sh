#!/bin/bash

# This script used to list all suffixes in the folder
# $1 The folder to search.

find $1 -type f | awk ' 
BEGIN {
	maxLen = 0;
}
{
	# Split the file by separator
	n = split($0, a, "/");
	# Match the suffix of file
	# ".gitignore" will be treat as has no suffix.
	# ".file.dat" will be treat as has suffix.
	n1 = match(a[n], /^.+\.[^\.]+$/);
	if (n1 != 0) {
		n2 = match(a[n], /\.[^\.]+$/);
		suffix = substr(a[n], n2, length(a[n]) - n2 + 1);
	}
	else {
		suffix = "no suffix";
	}
	
	suffixMap[suffix] += 1;
	if (maxLen < length(suffix)) {
		maxLen = length(suffix);
	}
}
END {
	format = "%-" maxLen + 1 "s:%3d\n"
	for (k in suffixMap)
		printf format, k, suffixMap[k];
}'
