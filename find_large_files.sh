#!/bin/bash

# Function to convert bytes to human-readable format
human_readable() {
    local size=$1
    awk -v size="$size" '
        BEGIN {
            if (size >= 1000000000) {
                printf "%.2fGB\n", size/1000000000
            } else if (size >= 1000000) {
                printf "%.2fMB\n", size/1000000
            } else if (size >= 1000) {
                printf "%.2fKB\n", size/1000
            } else {
                printf "%dB\n", size
            }
        }'
}

# Find files larger than 100MB
if [ "$(uname)" = "Darwin" ]; then
    # macOS version using stat
    find . -type f -size +100M -exec stat -f "%z %N" {} + 2>/dev/null | \
        while IFS=' ' read -r size file; do
            human=$(human_readable "$size")
            echo "$size $human $file"
        done | sort -rh -k1 | cut -d' ' -f2-
else
    # Linux version using find -printf
    find . -type f -size +100M -printf "%s\t%p\n" | \
        while IFS=$'\t' read -r size file; do
            human=$(human_readable "$size")
            echo "$size $human $file"
        done | sort -rh -k1 | cut -d' ' -f2-
fi
