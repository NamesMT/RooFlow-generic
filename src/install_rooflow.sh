#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting RooFlow config setup ---"

# Define a temporary directory name for clarity
TEMP_EXTRACT_DIR=".tmp-RooFlow_$$/" # Using $$ for process ID to add uniqueness

# Download the latest release
echo "Cloning RooFlow repository into $TEMP_EXTRACT_DIR..."
mkdir $TEMP_EXTRACT_DIR
wget https://github.com/NamesMT/RooFlow-generic/releases/latest/download/dist.tar.gz -O- | tar -xz -C $TEMP_EXTRACT_DIR

# --- MODIFIED COPY SECTION START ---
echo "Copying specific configuration items..."

# 1. Copy .roo directory (recursively)
echo "Copying .roo directory..."
# Use -T with cp to copy contents *into* the destination if it exists,
# but here we expect ./ to exist and ./.roo not to, so standard -r is fine.
cp -r "$TEMP_EXTRACT_DIR/.roo" ./

# 2. Copy specific config files
echo "Copying .roomodes..."
cp "$TEMP_EXTRACT_DIR/.roomodes" ./

# --- MODIFIED COPY SECTION END ---


# --- MODIFIED CLEANUP SECTION START ---
echo "Cleaning up .tmp directory..."
rm -r ".tmp"
# --- MODIFIED CLEANUP SECTION END ---


# Check if essential files exist before running
if [ ! -d ".roo" ]; then
    echo "Error: .roo directory not found after specific copy. Setup failed."
    exit 1
fi


echo "Scheduling self-deletion of install_rooflow.sh..."
# Use nohup for more robust background execution, redirect output
nohup bash -c "sleep 1 && rm -f '$0'" > /dev/null 2>&1 &

echo "--- RooFlow config setup complete ---"
exit 0 # Explicitly exit with success code
