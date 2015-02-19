#!/bin/bash

# This script used to list all suffixes in the folder
# $1 The folder to search.

find $1 -type f | awk ' {
	n = split($0, a, "/");
	n1 = match(a[n], /^\./);
	if (n1 == 0) {
		n2 = match(a[n], /\.[^\.]+$/);
		if (n2 != 0) {
			suffix = substr(a[n], n2 + 1, length(a[n]) - n2);
			m[suffix] += 1;
		}
	}
}
END {
 	for (k in m)
 		print k, ":", m[k];
}'
