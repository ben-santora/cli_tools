# Recursive File Extension Sorter (Enhanced-1/26)

A robust bash script that recursively organizes files by their extensions with advanced features like duplicate handling, disk space warnings, and flexible configuration options.

## What It Does

✅ **Recursively scans** all subdirectories in the source directory  
✅ **Copies or moves files** (preserving timestamps) to a configurable output directory  
✅ **Organizes files** into subdirectories based on their file extensions  
✅ **Handles duplicate filenames** by adding numeric suffixes (`_1`, `_2`, etc.)  
✅ **Shows disk space analysis** with warnings before processing  
✅ **Provides dry-run mode** to preview changes without modifying files  
✅ **Offers progress reporting** during the copying/moving process  
✅ **Includes comprehensive error handling** with detailed feedback  
✅ **Supports custom output directory names**  

## New Features

### 🆕 **Duplicate File Handling**
- Automatically renames duplicate files with numeric suffixes
- Example: `document.pdf` → `document_1.pdf`, `document_2.pdf`

### 🆕 **Disk Space Management**
- Calculates source directory size
- Estimates final directory size
- Warns if insufficient disk space is available
- Shows final organized directory size

### 🆕 **Flexible Configuration**
- Custom output directory names
- Choice between copy or move operations
- Dry-run mode for safe testing

### 🆕 **Enhanced Error Handling**
- Graceful handling of permission errors
- Detailed error messages for troubleshooting
- Continues processing when individual files fail

## Usage

### Command Line Options

```bash
Usage: ./sort_by_ext_recursive.sh [SOURCE_DIR] [OPTIONS]

Options:
  -o, --output DIR     Set output directory name (default: sorted_files)
  -d, --dry-run        Show what would be done without making changes
  -m, --move           Move files instead of copying
  -h, --help           Show this help message
```

### Basic Usage

```bash
# Make the script executable (first time only)
chmod +x sort_by_ext_recursive.sh

# Sort files in the current directory (copy mode)
./sort_by_ext_recursive.sh

# Sort files in a specific directory with custom output name
./sort_by_ext_recursive.sh /path/to/directory -o organized_files

# Preview what would be done without making changes
./sort_by_ext_recursive.sh /path/to/directory --dry-run

# Move files instead of copying
./sort_by_ext_recursive.sh /path/to/directory --move -o backup
```

### Examples

```bash
# Basic copy operation with default output directory
./sort_by_ext_recursive.sh ~/Documents

# Move files to a custom named directory
./sort_by_ext_recursive.sh ~/Downloads --move -o downloads_sorted

# Dry run to see what would happen
./sort_by_ext_recursive.sh ~/Pictures --dry-run

# Custom output directory with copy operation
./sort_by_ext_recursive.sh ~/Projects -o project_files
```

## Output Structure

The script creates a configurable output directory (default: `sorted_files`) in the source directory:

```
source_directory/
├── sorted_files/                    # or custom name
│   ├── pdf/
│   │   ├── document.pdf
│   │   ├── document_1.pdf           # duplicate handling
│   │   └── report.pdf
│   ├── jpg/
│   │   ├── photo.jpg
│   │   └── photo_1.jpg              # duplicate handling
│   ├── txt/
│   │   └── notes.txt
│   ├── no_extension/
│   │   └── README
│   └── ...
```

## Disk Space Management

The script now includes intelligent disk space management:

1. **Pre-analysis**: Calculates source directory size
2. **Space estimation**: Estimates final directory size
3. **Available space check**: Compares with available disk space
4. **Warning system**: Alerts if space might be insufficient
5. **User confirmation**: Asks for confirmation if space is tight

Example output:
```
Analyzing source directory...
Source directory size: 2.5GB
Estimated final size: 2.5GB
Available disk space: 15.2GB
Disk space appears sufficient for operation.
```

## Safety Features

### 🛡️ **Dry Run Mode**
Test the script without making any changes:
```bash
./sort_by_ext_recursive.sh ~/Documents --dry-run
```

### 🛡️ **Duplicate Protection**
- Automatic filename conflict resolution
- Preserves all files with numeric suffixes
- Reports duplicate handling during processing

### 🛡️ **Error Recovery**
- Continues processing if individual files fail
- Detailed error reporting
- Graceful handling of permission issues

## Important Warnings

> [!WARNING]
> **Disk Space**: The script now warns you about disk space usage before proceeding, but always ensure you have adequate space for the operation.

> [!CAUTION]
> **Move Operations**: Using `--move` permanently relocates files. Use `--dry-run` first to verify the operation.

> [!NOTE]
> **Hidden Files**: The script still skips hidden files (starting with `.`) for safety.

## How It Works

1. **Argument Parsing**: Processes command line options and parameters
2. **Space Analysis**: Calculates disk space requirements and availability
3. **Safety Check**: Warns user if space might be insufficient
4. **File Discovery**: Uses `find` to locate all files recursively
5. **Processing**: Copies or moves files with duplicate handling
6. **Organization**: Groups files by extension into subdirectories
7. **Reporting**: Provides detailed statistics and final directory size

## Testing Recommendations

### Safe Testing Workflow

```bash
# 1. Always start with dry run
./sort_by_ext_recursive.sh ~/test_directory --dry-run

# 2. Test with copy mode on small directory
./sort_by_ext_recursive.sh ~/small_test

# 3. Verify results before using move mode
ls -la ~/small_test/sorted_files/

# 4. Only then consider move mode
./sort_by_ext_recursive.sh ~/small_test --move -o backup
```

## Troubleshooting

**Problem**: "Permission denied" error  
**Solution**: `chmod +x sort_by_ext_recursive.sh` and ensure write permissions to target directory

**Problem**: "Insufficient disk space" warning  
**Solution**: Free up disk space or use `--move` instead of copy mode

**Problem**: Script takes too long  
**Solution**: Use `--dry-run` first to see file count, consider processing smaller subdirectories

**Problem**: Some files failed to process  
**Solution**: Check error messages - script continues processing other files and reports failures

**Problem**: Want to include hidden files  
**Solution**: Modify the `find` command in the script to remove the `! -path '*/\.*'` filter

## Performance Considerations

- **Large Directories**: Use `--dry-run` first to estimate processing time
- **Network Drives**: May be slower due to I/O operations
- **SSD vs HDD**: Performance varies by storage type
- **Memory Usage**: Script is memory-efficient for large directory trees

## Migration from Previous Version

If you used the old version:
- The basic usage remains the same: `./sort_by_ext_recursive.sh /path/to/dir`
- New features are optional - existing workflows continue to work
- Consider using `--dry-run` to familiarize yourself with the new output format
- The duplicate handling feature prevents data loss from filename conflicts

## License

Free to use and modify as needed. Perfect for personal file organization tasks.
