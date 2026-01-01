Recursive File Extension Sorter 

A simple and efficient Bash script to organize messy directories by sorting files into subfolders based on their file extensions. 
Features 

     Recursive Sorting: Scans the current directory (or a specified one) and all subdirectories.
     Extension Organization: Automatically creates folders for each file extension (e.g., jpg, png, pdf, txt).
     Case Insensitive: Converts extensions to lowercase to ensure File.JPG and file.jpg go into the same folder.
     No-Extension Support: Files without an extension are moved to a dedicated no_extension folder.
     Safe Operation: Uses cp -p to copy files rather than moving them, preserving permissions and timestamps. Your original files remain untouched.
     Hidden Files: Skips hidden files and directories (those starting with a dot .).
     Progress Feedback: Displays a progress counter every 100 files and provides a detailed summary upon completion.
     

Requirements 

     A Unix-like operating system (Linux, macOS, etc.).
     Bash shell.
     Standard utilities: find, mkdir, cp, sort, tr.
     

Installation 

    Download the script and save it as sort_files.sh (or your preferred name). 
    Make the script executable:
    bash
     
      

    chmod +x sort_files.sh
     
     
      

Usage 
Basic Usage 

Run the script from inside the directory you want to organize (it will organize the current folder): 
bash
 
  
./sort_files.sh
 
 
 
Specify a Directory 

You can pass a specific directory path as an argument: 
bash
 
  
./sort_files.sh /path/to/your/messy/folder
 
 
 
How It Works 

    The script scans the target directory recursively using find. 
    It identifies the extension of every file. 
    It creates a master directory named sorted_files inside the target directory. 
    Inside sorted_files, it creates subdirectories corresponding to the file extensions found (e.g., sorted_files/images/). 
    It copies the files into their respective subdirectories. 
    It prints a summary of how many files were processed for each extension type. 

Example Output 
text
 
  
Scanning and organizing files in '/home/user/Downloads'...
This may take a while for large directories.

Processed 100 files...
Processed 200 files...

Sorting complete! Processed 245 files.
Files organized by extension:
  docx: 15 files
  jpg: 120 files
  mp3: 45 files
  no_extension: 5 files
  pdf: 60 files

All files have been copied to: /home/user/Downloads/sorted_files
Note: Original files remain unchanged.
 
 
 
Important Notes 

     Copying vs. Moving: This script copies files. It does not delete the originals. If you are happy with the result and want to save space, you will need to manually delete the source files or modify the script to use mv instead of cp.
     Collisions: If two files in different source subdirectories have the exact same name and extension, the one processed last will overwrite the previous one in the sorted_files folder.
     System Resources: On directories with tens of thousands of files, the operation may take some time and utilize significant disk I/O.
     

Troubleshooting 

     Permission Denied: Ensure you have read permissions for the source directory and write permissions for the target directory.
     Command Not Found: Ensure you are running this in a Bash shell. If on macOS, the default terminal is usually Bash (or Zsh which is compatible).
     

   
