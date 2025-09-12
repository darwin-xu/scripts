#!/bin/bash

# Configuration variables
REMOTE_HOST="35.234.22.51"
REMOTE_USER="darwin"
DOWNLOAD_URL=$1
LOCAL_DESTINATION="."

# Display script banner
echo "==============================================="
echo "Automated Remote Download Script"
echo "==============================================="

# Step 1: SSH into remote server and download the file
echo "Step 1: Logging into remote server and downloading file..."
ssh ${REMOTE_USER}@${REMOTE_HOST} "wget ${DOWNLOAD_URL} -q --show-progress"

# Check if download was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to download the file on the remote server."
    exit 1
fi
echo "File downloaded successfully on remote server."

# Step 2: Copy the file from remote server to local machine
echo "Step 2: Copying file from remote server to local machine..."
FILENAME=$(basename ${DOWNLOAD_URL})
scp ${REMOTE_USER}@${REMOTE_HOST}:${FILENAME} ${LOCAL_DESTINATION}

# Check if copy was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy the file from remote server."
    exit 1
fi
echo "File copied successfully to local machine at ${LOCAL_DESTINATION}/${FILENAME}"

# Step 3: Remove the file from remote server
echo "Step 3: Removing file from remote server..."
ssh ${REMOTE_USER}@${REMOTE_HOST} "rm ${FILENAME}"

echo "==============================================="
echo "Download process completed successfully!"
echo "==============================================="
