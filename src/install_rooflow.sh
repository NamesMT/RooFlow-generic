#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting RooFlow config setup ---"

# Check for Git command
if ! command -v git &> /dev/null; then
    echo "Error: git is not found in your PATH."
    echo "Please install Git using your distribution's package manager (e.g., sudo apt install git, sudo yum install git)."
    exit 1
else
    echo "Found git executable."
fi

# Define a temporary directory name for clarity
CLONE_DIR="RooFlow_temp_$$" # Using $$ for process ID to add uniqueness

# Clone the repository (shallow clone for efficiency)
echo "Cloning RooFlow repository into $CLONE_DIR..."
git clone --depth 1 https://github.com/GreatScottyMac/RooFlow "$CLONE_DIR"

# --- MODIFIED COPY SECTION START ---
echo "Copying specific configuration items..."

# 1. Copy .roo directory (recursively)
echo "Copying .roo directory..."
# Use -T with cp to copy contents *into* the destination if it exists,
# but here we expect ./ to exist and ./.roo not to, so standard -r is fine.
cp -r "$CLONE_DIR/src/.roo" ./

# 2. Copy specific config files
echo "Copying .roomodes, insert-variables.sh..."
cp "$CLONE_DIR/src/.roomodes" ./
cp "$CLONE_DIR/src/insert-variables.sh" ./

# --- MODIFIED COPY SECTION END ---


# Make the setup script executable
echo "Setting permissions for insert-variables.sh..."
chmod +x insert-variables.sh


# --- MODIFIED CLEANUP SECTION START ---
echo "Cleaning up temporary clone directory ($CLONE_DIR)..."
rm -rf "$CLONE_DIR" # Remove the cloned repo directory

# Removed rm -f insert-variables.cmd   (never copied)
# Removed rm -rf default-mode          (never copied)
# --- MODIFIED CLEANUP SECTION END ---


# Check if essential files exist before running
if [ ! -d ".roo" ]; then
    echo "Error: .roo directory not found after specific copy. Setup failed."
    exit 1
fi
if [ ! -f "insert-variables.sh" ]; then
     echo "Error: insert-variables.sh not found after specific copy. Setup failed."
     exit 1
fi


# Run the setup script
echo "Running insert-variables.sh..."
./insert-variables.sh

echo "insert-variables.sh completed successfully. Removing it..."
rm -f insert-variables.sh


echo "Scheduling self-deletion of install_rooflow.sh..."
# Use nohup for more robust background execution, redirect output
nohup bash -c "sleep 1 && rm -f '$0'" > /dev/null 2>&1 &

echo "--- RooFlow config setup complete ---"
exit 0 # Explicitly exit with success code
