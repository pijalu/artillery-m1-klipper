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

# Check .version file first
VERSION_FILE="$CONFIG_DIR/.version"
TARGET_VERSION_FILE="$TARGET_DIR/.version"

# If .version file exists, check if it's the same as target
if [ -f "$VERSION_FILE" ] && [ -f "$TARGET_VERSION_FILE" ]; then
    if cmp -s "$VERSION_FILE" "$TARGET_VERSION_FILE"; then
        echo "Version file is identical, no deployment needed"
        exit 1
    fi
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

# Flag to track if any files were modified
FILES_MODIFIED=false

# Process each config file excluding .version
for file in "$CONFIG_DIR"/*.{cfg,conf,txt,ini}; do
    # Check if file exists (in case no files match the pattern)
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        target_file="$TARGET_DIR/$filename"
        
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
                FILES_MODIFIED=true
            else
                echo "File $filename is identical, skipping"
            fi
        else
            # Target file doesn't exist, just copy
            echo "Copying $file to $target_file"
            if [ "$DRY_RUN" = false ]; then
                cp "$file" "$target_file"
            fi
            FILES_MODIFIED=true
        fi
    fi
done

# Handle .version file separately
if [ -f "$VERSION_FILE" ]; then
    filename=$(basename "$VERSION_FILE")
    target_file="$TARGET_DIR/$filename"
    
    # Always copy .version file as it's the trigger for deployment
    if [ -f "$target_file" ]; then
        echo "Backing up $target_file to $target_file.backup_$TIMESTAMP"
        if [ "$DRY_RUN" = false ]; then
            cp "$target_file" "$target_file.backup_$TIMESTAMP"
        fi
    fi
    echo "Copying $VERSION_FILE to $target_file"
    if [ "$DRY_RUN" = false ]; then
        cp "$VERSION_FILE" "$target_file"
    fi
    FILES_MODIFIED=true
fi

if [ "$DRY_RUN" = true ]; then
    echo "=== DRY RUN COMPLETE ==="
    echo "No files were copied or modified"
    echo "========================"
else
    if [ "$FILES_MODIFIED" = false ]; then
        echo "No files were modified during deployment"
        exit 1
    else
        echo "File copy operation completed"
    fi
fi