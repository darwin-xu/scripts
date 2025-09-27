#!/usr/bin/env python3

"""
List MOV files shorter than a given duration.

Requires:
    - exiftool (https://exiftool.org) available on PATH

Usage:
    python find_live.py [--max-seconds 3] <directory>

Behavior:
        - Recursively search for .mov / .MOV files beneath the directory.
        - Print paths of files whose duration is less than the max seconds.

The default max duration is 3 seconds.
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


def find_short_videos(directory: str, max_seconds: float) -> List[str]:
    """Return MOV file paths shorter than ``max_seconds`` under ``directory``."""

    directory = os.path.abspath(directory)

    # Duration# exposes the raw duration value in seconds; guard against missing data.
    filter_expr = f"defined $Duration# and $Duration# > 0 and $Duration# < {max_seconds}"

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
        description="List MOV files shorter than a specified duration",
    )
    parser.add_argument(
        "directory",
        help="Directory to search recursively",
    )
    parser.add_argument(
        "--max-seconds",
        type=float,
        default=3.0,
        help="Maximum duration (seconds) for a video to be listed (default: 3)",
    )
    return parser.parse_args(argv[1:])


def main(argv: List[str]) -> int:
    args = parse_args(argv)

    if not os.path.isdir(args.directory):
        print(f"Error: not a directory: {args.directory}", file=sys.stderr)
        return 1

    ensure_exiftool_available()

    paths = find_short_videos(args.directory, max_seconds=args.max_seconds)
    for p in paths:
        print(p)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
