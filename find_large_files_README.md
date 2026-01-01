# Large File Finder Script

This Bash script helps identify and list files larger than 100 megabytes in the current directory and its subdirectories. It displays each file's size in a human-readable format (GB, MB, KB, or B) alongside its path, sorted from largest to smallest.

## Features

- Cross-platform compatibility: supports both Linux and macOS
- Human-readable size output with precision up to two decimal places
- Efficiently processes large directory trees using `find`
- Sorts results by file size in descending order
- Gracefully handles errors (e.g., permission issues)

## Usage

Run the script from any directory where you want to find large files:

```bash
./find_large_files.sh