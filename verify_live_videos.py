#!/usr/bin/env python3

"""
Verify iPhone Live Photo companion videos (report problems).

For every .mov/.MOV file under a given directory (recursively), emit the file's
absolute path IF it FAILS to satisfy BOTH conditions:
    1. A sibling still image (.HEIC/.JPG/.JPEG, case-insensitive) with the same
         basename exists in the same directory.
    2. The video duration is less than 3 seconds.

Requirements:
        - exiftool (https://exiftool.org) available on PATH.

Usage:
  python verify_live_videos.py [-v] <directory>

Behavior:
    - Prints NON-qualifying .MOV file paths (one per line).
  - With -v prints verbose progress messages to stderr.
  - Exits non‑zero on basic argument / environment errors only; missing tags
    simply exclude files from output.
"""

import argparse
import os
import shutil
import subprocess
import sys
from typing import List, Optional


def log(verbose: bool, msg: str) -> None:
    if verbose:
        print(msg, file=sys.stderr)


def ensure_exiftool_available(verbose: bool) -> None:
    if shutil.which("exiftool") is None:
        log(verbose, "exiftool not found on PATH")
        print("Error: exiftool not found on PATH. Install it and try again.", file=sys.stderr)
        sys.exit(2)
    log(verbose, "exiftool found")


def gather_mov_files(root: str, verbose: bool) -> List[str]:
    movs: List[str] = []
    for dirpath, _dirnames, filenames in os.walk(root):
        for name in filenames:
            if name.lower().endswith(".mov"):
                movs.append(os.path.abspath(os.path.join(dirpath, name)))
    log(verbose, f"Found {len(movs)} .mov files")
    return movs


def has_matching_still(path: str) -> bool:
    base = os.path.splitext(os.path.basename(path))[0].lower()
    dirpath = os.path.dirname(path)
    for name in os.listdir(dirpath):
        stem, ext = os.path.splitext(name)
        if stem.lower() == base and ext.lower() in {".heic", ".jpg", ".jpeg"}:
            return True
    return False


def get_duration_seconds(path: str, verbose: bool) -> Optional[float]:
    cmd = ["exiftool", "-s3", "-Duration#", path]
    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    if result.returncode != 0:
        log(verbose, f"exiftool duration lookup failed for {path}: {result.stderr.strip()}")
        return None
    value = result.stdout.strip()
    if not value:
        return None
    try:
        return float(value)
    except ValueError:
        log(verbose, f"Could not parse duration '{value}' for {path}")
        return None


def is_live_mov(path: str, verbose: bool) -> bool:
    has_still = has_matching_still(path)
    duration = get_duration_seconds(path, verbose)
    is_live = has_still and duration is not None and duration < 4.0
    if verbose:
        log(
            verbose,
            f"LIVE[{is_live}] {path} (still={has_still} duration={duration})",
        )
    return is_live


def find_non_live_movs(movs: List[str], verbose: bool) -> List[str]:
    return [path for path in movs if not is_live_mov(path, verbose)]


def parse_args(argv: List[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Verify live video companion files (MOV + HEIC)",
    )
    parser.add_argument("directory", help="Root directory to search recursively")
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Print progress information to stderr",
    )
    return parser.parse_args(argv[1:])


def main(argv: List[str]) -> int:
    args = parse_args(argv)

    if not os.path.isdir(args.directory):
        print(f"Error: not a directory: {args.directory}", file=sys.stderr)
        return 1

    root = os.path.abspath(args.directory)
    ensure_exiftool_available(args.verbose)
    log(args.verbose, f"Scanning: {root}")

    movs = gather_mov_files(root, args.verbose)
    non_live = find_non_live_movs(movs, args.verbose)
    log(args.verbose, f"Non-qualifying MOV files: {len(non_live)}")

    for path in non_live:
        print(path)

    return 0


if __name__ == "__main__":  # pragma: no cover
    raise SystemExit(main(sys.argv))
