#!/bin/bash

# This script used to list all suffixes in the folder
# $1 The folder to search.

find $1 -type f | awk ' 
BEGIN {
	maxSuffixLen = 0;
	maxLenLen = 0;
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
		if (length(noSuffix) == 0) {
			noSuffix = $0
		}
		else {
			noSuffix = noSuffix "\n" $0
		}
	}
	
	suffixMap[suffix] += 1;
	if (maxSuffixLen < length(suffix)) {
		maxSuffixLen = length(suffix);
	}

	if (maxLenLen < length(suffixMap[suffix])) {
		maxLenLen = length(suffixMap[suffix]);
	}
}
END {
	print "Files type statistics:"
	format = "%-" maxSuffixLen + 1 "s:%" maxLenLen + 1 "d\n"
	for (k in suffixMap)
		printf format, k, suffixMap[k];
	print "\nFiles without suffix:"
	print noSuffix
}'
