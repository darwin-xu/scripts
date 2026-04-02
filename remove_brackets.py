#!/usr/bin/env python3

import os
import re
import sys

def clean_filename(name: str) -> str:
    # Remove " (number)" pattern, e.g. "IMG_0252 (1).mov" -> "IMG_0252.mov"
    return re.sub(r" \(\d+\)", "", name)

def rename_files(root="."):
    for dirpath, _, filenames in os.walk(root):
        for filename in filenames:
            new_name = clean_filename(filename)
            if new_name != filename:
                old_path = os.path.join(dirpath, filename)
                new_path = os.path.join(dirpath, new_name)
                print(f"Renaming: {old_path} -> {new_path}")
                os.rename(old_path, new_path)

if __name__ == "__main__":
    rename_files(sys.argv[1])  # change "." to any directory you want
