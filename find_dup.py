#!/usr/bin/env python3

import os
import hashlib
from collections import defaultdict


def get_file_size(file_path):
    """Return the size of the file."""
    try:
        return os.path.getsize(file_path)
    except OSError:
        return -1


def compute_md5(file_path):
    """Compute MD5 hash of the file."""
    hash_md5 = hashlib.md5()
    try:
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()
    except OSError:
        return None


def find_duplicates(directory):
    """Find and print duplicate files in the directory and its subdirectories."""
    files_by_size = defaultdict(list)

    # Walk through all directories and group files by size
    for root, _, files in os.walk(directory):
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
                file_hash = compute_md5(file_path)
                if file_hash:
                    seen_hashes[file_hash].append(file_path)

            # Print duplicates (files with the same hash)
            for file_hash, duplicates in seen_hashes.items():
                if len(duplicates) > 1:
                    print(f"Duplicate files (MD5 hash: {file_hash}):")
                    for path in duplicates:
                        print(f"  {path}")


if __name__ == "__main__":
    directory = input("Enter the directory to search for duplicates: ")
    find_duplicates(directory)
