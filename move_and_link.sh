#!/bin/bash

# Exit immediately if a command returns a non-zero status
set -e

# Usage message
usage() {
    echo "Usage: $0 <file>"
    echo "Provide the filename as an argument to move it and create a symlink."
    exit 1
}

# Check if a file argument is provided
if [[ -z "$1" ]]; then
    echo "Error: No file specified."
    usage
fi

file=$1
file_path=$(realpath -m "$file") # Use -m to allow non-existing paths
filename=$(basename "$file_path")
origin_path=$(dirname "$file_path")
script_path=$(dirname "$(readlink -f "$0")")

# Determine the OS type and set the corresponding platform
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    platform="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    platform="macos"
elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    platform="windows"
else
    echo "Error: Unsupported platform: $OSTYPE"
    exit 1
fi

# Preserve the full path starting from root, including the home directory
home_dir=$(realpath ~)
if [[ "$file_path" == "$home_dir"* ]]; then
    # Path relative to home directory
    relative_path=${file_path#$home_dir/}
    target_path="$script_path/$platform/home/$relative_path"
else
    # Path relative to root for non-home files
    relative_path=${file_path#/}
    target_path="$script_path/$platform/$relative_path"
fi

echo "Target path for file: $target_path"

if [[ -f "$file_path" ]]; then
    echo "File exists at the original location."

    # Create the target directory, preserving the relative structure
    mkdir -p "$(dirname "$target_path")"

    # Move the file to the target directory
    mv "$file_path" "$target_path"

    # Check if a file or symlink already exists at the original location
    if [[ -e "$file_path" ]]; then
        echo "Error: A file or directory already exists at $file_path."
        exit 1
    fi

    # Create a symlink in the original location pointing to the repo file
    ln -s "$target_path" "$file_path"

    echo "Successfully moved $filename to $target_path and created symlink."
elif [[ -f "$target_path" ]]; then
    echo "File does not exist at the original location but exists in the repo."

    # Check if a file or symlink already exists at the original location
    if [[ -e "$file_path" ]]; then
        echo "Error: A file or directory already exists at $file_path."
        exit 1
    fi

    # Create a symlink in the original location pointing to the repo file
    ln -s "$target_path" "$file_path"

    echo "Successfully created symlink at $file_path pointing to $target_path."
else
    echo "Error: File does not exist at the original location or in the repo."
    exit 1
fi
