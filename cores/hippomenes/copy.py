import os
import shutil

# Define the source file and the destination directory
source_file = 'hippomenes_veryl.f'
destination_dir = './hippo/'

# Create the destination directory if it doesn't exist
os.makedirs(destination_dir, exist_ok=True)

# Open the source file and read the paths
with open(source_file, 'r') as file:
    for line in file:
        # Strip any whitespace characters (like newline)
        file_path = line.strip()
        
        # Check if the file exists
        if os.path.isfile(file_path):
            # Get the filename from the path
            filename = os.path.basename(file_path)
            # Define the destination path
            dest_path = os.path.join(destination_dir, filename)
            # Copy the file
            shutil.copy(file_path, dest_path)
            print(f'Copied: {file_path} to {dest_path}')
        else:
            print(f'File not found: {file_path}')