#!/usr/bin/env python3

"""
List iPhone Live Photo videos by tag only (no duration/aspect heuristics).

Requires:
  - exiftool (https://exiftool.org) available on PATH

Usage:
  python find_live_by_tag.py <directory>

Prints absolute paths of .MOV files that have the Keys:LivePhotoAuto tag set to 1.
"""

import os
import shutil
import subprocess
import sys
from typing import List


def ensure_exiftool_available() -> None:
    if shutil.which("exiftool") is None:
        print("Error: exiftool not found on PATH. Install it and try again.", file=sys.stderr)
        sys.exit(2)


def find_live_videos_by_tag(directory: str) -> List[str]:
    """Return a list of file paths under 'directory' that are Live Photos by tag.

    Uses a single exiftool call with a filter expression:
      -r                        recurse
      -ext mov / -ext MOV      match QuickTime movie files
      -if defined $Keys:LivePhotoAuto and $Keys:LivePhotoAuto eq 1
      -p $FilePath             print the full file path only
    """

    # Normalize directory to absolute path so printed results are absolute.
    directory = os.path.abspath(directory)

    cmd = [
        "exiftool",
        "-r",
        "-ext",
        "mov",
        "-ext",
        "MOV",
        # Hint to exiftool to emit filenames as UTF-8 where possible.
        "-charset",
        "filename=UTF8",
        "-if",
        "defined $Keys:LivePhotoAuto and $Keys:LivePhotoAuto eq 1",
        "-p",
        "$FilePath",
        directory,
    ]

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=False,  # read bytes to avoid decoding issues
    )

    raw_lines = [line.strip() for line in result.stdout.splitlines()]
    # Keep only existing paths first using bytes paths (OS APIs accept bytes paths on POSIX)
    byte_paths = [p for p in raw_lines if p and os.path.isfile(p)]

    # Decode to str safely; preserve undecodable bytes using surrogateescape
    paths = [p.decode("utf-8", errors="surrogateescape") for p in byte_paths]
    return paths


def main(argv: List[str]) -> int:
    if len(argv) != 2:
        print("Usage: python find_live_by_tag.py <directory>")
        return 1

    ensure_exiftool_available()

    directory = argv[1]
    if not os.path.isdir(directory):
        print(f"Error: not a directory: {directory}", file=sys.stderr)
        return 1

    live_paths = find_live_videos_by_tag(directory)
    for p in live_paths:
        print(p)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
