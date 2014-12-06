#!/bin/bash

# $1 the source directory
# $2 the destination directory

find $1 -type f -exec safemv {} $2 \;
