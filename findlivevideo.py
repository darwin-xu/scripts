#!/usr/bin/env python3

import os
import subprocess
import sys
import shutil
import hashlib


def find_iphone_live_videos(directory):
    live_videos = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".MOV") or file.endswith(".mov"):

                def get_video_duration(file_path):
                    result = subprocess.run(
                        [
                            "exiftool",
                            "-Video:Duration#",
                            "-ImageWidth",
                            "-ImageHeight",
                            "-s3",
                            file_path,
                        ],
                        stdout=subprocess.PIPE,
                        stderr=subprocess.STDOUT,
                    )
                    output = result.stdout.decode().split()
                    if len(output) != 3:
                        return float("inf")
                    duration = float(output[0])
                    width = int(output[1])
                    height = int(output[2])
                    if (
                        abs((width / height) - (4 / 3)) < 0.001
                        or abs((width / height) - (3 / 4)) < 0.001
                    ):
                        return duration
                    else:
                        return float("inf")
                    return float(result.stdout)

                duration = get_video_duration(os.path.join(root, file))
                if duration <= 3:
                    live_videos.append(os.path.join(root, file))
    return live_videos


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python findlivevideo.py <directory> <target>")
        sys.exit(1)
    directory = sys.argv[1]
    live_videos = find_iphone_live_videos(directory)
    for video in live_videos:
        result = subprocess.run(
            ["exiftool", "-Keys:LivePhotoAuto", "-s3", video],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
        # Print live photo based on output, if it is 1, then live photo, other wise, no.
        if result.stdout.decode().strip() == "1":
            print(f"{video}: live photo. Removing file.")
            # os.remove(video)
            # print(f"{video}: live photo.")
            # target_directory = sys.argv[2]
            # if not os.path.exists(target_directory):
            #     os.makedirs(target_directory)
            # target_path = os.path.join(target_directory, os.path.basename(video))
            # #os.rename(video, target_path)
            # #os.move(video, target_path)
            # if os.path.exists(target_path):
            #     # Check if file exists and compare content
            #     if os.path.getsize(video) == os.path.getsize(target_path):
            #         # Files have the same size, so check the content with md5 hash
            #         with open(video, 'rb') as f1, open(target_path, 'rb') as f2:
            #             if hashlib.md5(f1.read()).hexdigest() == hashlib.md5(f2.read()).hexdigest():
            #                 print(f"Removing original file since duplicate exists in target.")
            #                 os.remove(video)
            #             else:
            #                 print(f"File exists with different content: {video}")
            #     else:
            #         print(f"File exists with different size: {video}")
            # else:
            #     print(f"Copy {video} to {target_path} and remove original")
            #     shutil.copy(video, target_path)  # copy the live photo
            #     os.remove(video)  # delete the original after copying
        else:
            print(f"{video}: not live photo.")
