#!/bin/bash

# Recursive File Extension Sorter
# Organizes files by their extensions into a sorted_files directory

# Default to current directory if no argument is provided
SOURCE_DIR="${1:-$(pwd)}"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Directory '$SOURCE_DIR' does not exist."
    exit 1
fi

# Create the sorted_files directory
SORTED_DIR="$SOURCE_DIR/sorted_files"
mkdir -p "$SORTED_DIR"

# Initialize counters
declare -A extension_counts
total_files=0

# Find all files (excluding hidden ones) and process them
echo "Scanning and organizing files in '$SOURCE_DIR'..."
echo "This may take a while for large directories."
echo ""

# Find all non-hidden files
find "$SOURCE_DIR" -type f ! -path '*/\.*' | while read -r file; do
    # Skip files already in the sorted directory
    if [[ "$file" == "$SORTED_DIR"* ]]; then
        continue
    fi
    
    # Get the filename and extension
    filename=$(basename "$file")
    
    # Extract extension
    if [[ "$filename" == *.* ]]; then
        extension="${filename##*.}"
        extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')  # Convert to lowercase
    else
        extension="no_extension"
    fi
    
    # Create directory for extension if it doesn't exist
    mkdir -p "$SORTED_DIR/$extension"
    
    # Copy file preserving timestamps
    cp -p "$file" "$SORTED_DIR/$extension/"
    
    # Update counters
    ((total_files++))
    ((extension_counts[$extension]++))
    
    # Show progress every 100 files
    if (( total_files % 100 == 0 )); then
        echo "Processed $total_files files..."
    fi
done

# Display summary
echo ""
echo "Sorting complete! Processed $total_files files."
echo "Files organized by extension:"

# Print extension counts in alphabetical order
for ext in $(printf '%s\n' "${!extension_counts[@]}" | sort); do
    echo "  $ext: ${extension_counts[$ext]} files"
done

echo ""
echo "All files have been copied to: $SORTED_DIR"
echo "Note: Original files remain unchanged."
