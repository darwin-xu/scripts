import os

def find_duplicates(directory):
    file_info = {}
    duplicates = []

    # Walk through the directory and check all files
    for dirpath, _, filenames in os.walk(directory):
        for filename in filenames:
            file_path = os.path.join(dirpath, filename)
            file_size = os.path.getsize(file_path)

            # Use (filename, size) as the key to track files
            file_key = (filename, file_size)

            # If this combination has already been seen, it's a duplicate
            if file_key in file_info:
                duplicates.append(file_path)
            else:
                file_info[file_key] = file_path

    return duplicates

def remove_files(file_list):
    for file_path in file_list:
        try:
            os.remove(file_path)
            print(f"Removed: {file_path}")
        except Exception as e:
            print(f"Failed to remove {file_path}: {e}")

def main():
    directory = input("Enter the directory path to scan for duplicates: ")
    
    if not os.path.isdir(directory):
        print("The provided path is not a valid directory.")
        return
    
    duplicates = find_duplicates(directory)
    
    if not duplicates:
        print("No duplicate files found.")
    else:
        print(f"Found {len(duplicates)} duplicate(s).")
        remove_confirmation = input("Do you want to remove these duplicates? (yes/no): ").strip().lower()
        
        if remove_confirmation == 'yes':
            remove_files(duplicates)
        else:
            print("No files were removed.")

if __name__ == "__main__":
    main()
