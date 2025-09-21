#!/usr/bin/env python3

import os
import sys
import hashlib
from collections import defaultdict
import argparse


def get_file_size(file_path):
    """Return the size of the file."""
    try:
        return os.path.getsize(file_path)
    except OSError:
        return -1


def compute_md5(file_path, verbose=False):
    """Compute MD5 hash of the file."""
    hash_md5 = hashlib.md5()
    try:
        if verbose:
            print(f"Calculating MD5: {file_path}")
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()
    except OSError:
        return None


def find_duplicates(directory, verbose=False, delete_newer=False):
    """Find and print duplicate files in the directory and its subdirectories."""
    files_by_size = defaultdict(list)

    # Walk through all directories and group files by size
    if verbose:
        print(f"Traversing directory: {directory}")
    for root, _, files in os.walk(directory):
        if verbose:
            print(f"  Found {len(files)} files in {root}")
        for file in files:
            file_path = os.path.join(root, file)
            file_size = get_file_size(file_path)
            if file_size > 0:
                files_by_size[file_size].append(file_path)

    # Compare files with the same size
    for size, file_paths in files_by_size.items():
        if len(file_paths) > 1:
            seen_hashes = defaultdict(list)
            for file_path in file_paths:
                file_hash = compute_md5(file_path, verbose=verbose)
                if file_hash:
                    seen_hashes[file_hash].append(file_path)

            # Handle duplicates (files with the same hash)
            for file_hash, duplicates in seen_hashes.items():
                if len(duplicates) > 1:
                    if delete_newer:
                        # Keep the oldest file by modification time, delete the rest
                        try:
                            dup_with_mtime = [
                                (path, os.path.getmtime(path)) for path in duplicates
                            ]
                            dup_with_mtime.sort(key=lambda x: (x[1], x[0]))
                            keep_path = dup_with_mtime[0][0]
                            to_delete = [p for p, _ in dup_with_mtime[1:]]
                            print(f"Keeping oldest (MD5 {file_hash}): {keep_path}")
                            for path in to_delete:
                                try:
                                    os.remove(path)
                                    print(f"Deleted newer duplicate: {path}")
                                except Exception as e:
                                    print(f"Failed to delete {path}: {e}")
                        except Exception as e:
                            print(
                                f"Error processing deletions for hash {file_hash}: {e}"
                            )
                    else:
                        print(f"Duplicate files (MD5 hash: {file_hash}):")
                        for path in duplicates:
                            print(f"  {path}")


def parse_args(argv=None):
    parser = argparse.ArgumentParser(
        description="Find duplicate files under a directory using size+MD5."
    )
    parser.add_argument(
        "directory",
        nargs="?",
        default=".",
        help="Directory to search (default: current directory)",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Print files as they are hashed",
    )
    parser.add_argument(
        "-d",
        "--delete-newer",
        action="store_true",
        help="Delete newer duplicates, keeping the oldest by mtime",
    )
    return parser.parse_args(argv)


if __name__ == "__main__":
    args = parse_args()
    dir_path = os.path.abspath(args.directory)
    if not os.path.isdir(dir_path):
        print(f"Error: '{args.directory}' is not a valid directory.", file=sys.stderr)
        sys.exit(1)
    find_duplicates(dir_path, verbose=args.verbose, delete_newer=args.delete_newer)
