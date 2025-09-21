#!/usr/bin/env python3
import os
import subprocess
import sys
import argparse

def check_image_with_exiftool(file_path):
    """Run exiftool on a file and return True if it has an Error field."""
    try:
        result = subprocess.run(
            ["exiftool", file_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        for line in result.stdout.splitlines():
            if line.startswith("Error"):
                return line.strip()
        return None
    except Exception as e:
        return f"Failed to check {file_path}: {e}"

def find_broken_images(directory):
    """Walk through the directory and find images with format errors."""
    broken_files = []
    for root, _, files in os.walk(directory):
        for name in files:
            if name.lower().endswith((".jpg", ".jpeg", ".png", ".heic", ".tiff", ".mp4", ".mov", ".mts")):
                file_path = os.path.join(root, name)
                error = check_image_with_exiftool(file_path)
                if error:
                    broken_files.append((file_path, error))
    return broken_files

def parse_args(argv=None):
    parser = argparse.ArgumentParser(description="Find images/videos with format errors using exiftool.")
    parser.add_argument("directory", help="Directory to scan")
    parser.add_argument(
        "-d",
        "--delete",
        action="store_true",
        help="Delete files that exiftool reports as having an Error",
    )
    return parser.parse_args(argv)


if __name__ == "__main__":
    args = parse_args()
    directory = args.directory

    if not os.path.isdir(directory):
        print("Invalid directory path.")
        sys.exit(1)

    broken_images = find_broken_images(directory)
    if not broken_images:
        print("No broken images found.")
    else:
        print(f"Found {len(broken_images)} broken image(s):\n")
        for path, error in broken_images:
            print(f"{path} -> {error}")
        if args.delete:
            print("\nDeleting broken files...")
            for path, _ in broken_images:
                try:
                    os.remove(path)
                    print(f"Deleted: {path}")
                except Exception as e:
                    print(f"Failed to delete {path}: {e}")
