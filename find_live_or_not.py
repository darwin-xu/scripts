#!/usr/bin/env python3

"""
List iPhone Live Photo videos by tag only (no duration/aspect heuristics),
or list non-live videos when requested.

Requires:
  - exiftool (https://exiftool.org) available on PATH

Usage:
  python find_live_or_not.py [--live] <directory>

Behavior:
  - With --live: print absolute paths of .MOV files that have Keys:LivePhotoAuto == 1.
  - Without --live: print absolute paths of .MOV files that DO NOT have Keys:LivePhotoAuto == 1.
"""

import argparse
import os
import shutil
import subprocess
import sys
from typing import List


def ensure_exiftool_available() -> None:
    if shutil.which("exiftool") is None:
        print("Error: exiftool not found on PATH. Install it and try again.", file=sys.stderr)
        sys.exit(2)


def find_videos_by_live_tag(directory: str, live: bool) -> List[str]:
    """Return a list of MOV file paths under 'directory' filtered by LivePhoto tag.

    Uses a single exiftool call with a filter expression:
      -r                        recurse
      -ext mov / -ext MOV      match QuickTime movie files
      -if <expr>               where <expr> depends on 'live'
      -p $FilePath             print the full file path only
    """

    directory = os.path.abspath(directory)

    if live:
        # Live when Keys:LivePhotoAuto is defined and equals 1
        filter_expr = "defined $Keys:LivePhotoAuto and $Keys:LivePhotoAuto eq 1"
    else:
        # Non-live when either undefined or not equal to 1
        # In exiftool, 'not(...)' and 'or' can be used. We ensure files exist either way.
        filter_expr = "not (defined $Keys:LivePhotoAuto and $Keys:LivePhotoAuto eq 1)"

    cmd = [
        "exiftool",
        "-r",
        "-ext",
        "mov",
        "-ext",
        "MOV",
        "-charset",
        "filename=UTF8",
        "-if",
        filter_expr,
        "-p",
        "$FilePath",
        directory,
    ]

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=False,
    )

    raw_lines = [line.strip() for line in result.stdout.splitlines()]
    byte_paths = [p for p in raw_lines if p and os.path.isfile(p)]
    paths = [p.decode("utf-8", errors="surrogateescape") for p in byte_paths]
    return paths


def parse_args(argv: List[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="List live or non-live iPhone Live Photo videos by tag",
    )
    parser.add_argument(
        "directory",
        help="Directory to search recursively",
    )
    parser.add_argument(
        "--live",
        action="store_true",
        help="List live videos (default lists non-live videos)",
    )
    return parser.parse_args(argv[1:])


def main(argv: List[str]) -> int:
    args = parse_args(argv)

    if not os.path.isdir(args.directory):
        print(f"Error: not a directory: {args.directory}", file=sys.stderr)
        return 1

    ensure_exiftool_available()

    paths = find_videos_by_live_tag(args.directory, live=args.live)
    for p in paths:
        print(p)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
