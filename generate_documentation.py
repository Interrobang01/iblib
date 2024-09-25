import os


print(os.listdir())

def process_files_in_directory(directory):
    string = ""
    for root, _, files in os.walk(directory):
        for filename in files:
            print("Trying "+filename+"...")
            file_path = os.path.join(root, filename)
            try:
                with open(file_path, 'r', encoding='utf-8') as file:
                    file_content = file.read()
                    if file_content != None:
                        string = string + "\n### " + filename.split(".")[0]
                        if file_path.find("components") != -1:
                            string = string + " (component)"
                        string = string + "\n" + extract_substring(file_content) + "\n"
                print("Success")
            except Exception as e:
                print(f"Error processing file {file_path}: {e}")
    return string

def extract_substring(s):
    start_marker = '--[['
    end_marker = '--]]'
    
    start_index = s.find(start_marker)
    end_index = s.find(end_marker, start_index)
    
    if start_index != -1 and end_index != -1:
        # Move the start index to the end of the start_marker
        start_index += len(start_marker)
        return s[start_index:end_index].strip()
    
    return None  # Return None if markers are not found

documentation = process_files_in_directory(r"lib")
readme_template_file = open(r"README_template.txt", "r")
readme_template = readme_template_file.read()
file_object = open(r"README.md", "w")
file_object.write(readme_template + documentation)
file_object.close()
