#!/bin/bash

# Parse command line options
DRY_RUN=false
TARGET_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# Check if target directory is provided
if [ -z "$TARGET_DIR" ]; then
    echo "Usage: $0 [--dry-run] <target_directory>"
    exit 1
fi

# Check if target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Target directory does not exist: $TARGET_DIR"
    exit 1
fi

CONFIG_DIR="$(dirname "$0")/config"

# Check if config directory exists
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Config directory does not exist: $CONFIG_DIR"
    exit 1
fi

# Create timestamp for backups (same for all files in this run)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

if [ "$DRY_RUN" = true ]; then
    echo "=== DRY RUN MODE ==="
    echo "No files will be copied or modified"
    echo "===================="
fi

echo "Copying files from $CONFIG_DIR to $TARGET_DIR"
echo "Backup timestamp: $TIMESTAMP"

# Process each config file
for file in "$CONFIG_DIR"/*.{cfg,conf,txt}; do
    # Check if file exists (in case no files match the pattern)
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        target_file="$TARGET_DIR/$filename"
        
        # Check if target file exists
        if [ -f "$target_file" ]; then
            # Compare files
            if ! cmp -s "$file" "$target_file"; then
                # Files are different, create backup
                echo "Backing up $target_file to $target_file.backup_$TIMESTAMP"
                if [ "$DRY_RUN" = false ]; then
                    cp "$target_file" "$target_file.backup_$TIMESTAMP"
                fi
                # Copy new file
                echo "Copying $file to $target_file"
                if [ "$DRY_RUN" = false ]; then
                    cp "$file" "$target_file"
                fi
            else
                echo "File $filename is identical, skipping"
            fi
        else
            # Target file doesn't exist, just copy
            echo "Copying $file to $target_file"
            if [ "$DRY_RUN" = false ]; then
                cp "$file" "$target_file"
            fi
        fi
    fi
done

if [ "$DRY_RUN" = true ]; then
    echo "=== DRY RUN COMPLETE ==="
    echo "No files were copied or modified"
    echo "========================"
else
    echo "File copy operation completed"
fi