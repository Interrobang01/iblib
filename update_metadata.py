import os

template_folder = r"metadatatemplates"

filepathes = {
    "readme_template": template_folder + "/" + r"README_template.txt",
    "description_template": template_folder + "/" + r"description_template.txt",
    "package_toml_description_template": template_folder + "/" + r"package_toml_description_template.txt",
    "version_num": r"current_version.txt"
}

# Check existence
if not os.path.exists(template_folder):
    raise FileNotFoundError(f"Template folder '{template_folder}' does not exist.")
for key, path in filepathes.items():
    if not os.path.exists(path):
        raise FileNotFoundError(f"Template file '{path}' for '{key}' does not exist.")

print(os.listdir())

def process_files_in_directory(directory):
    string = ""
    for root, _, files in os.walk(directory):
        for filename in files:
            print("Trying "+filename+"...")
            file_path = os.path.join(root, filename)
            try:
                with open(file_path, 'r', encoding='utf-8') as file:
                    file_content = extract_substring(file.read())
                    if file_content != None:
                        string = string + "\n### " + filename.split(".")[0]
                        if file_path.find("components") != -1:
                            string = string + " (component)"
                        string = string + "\n" + file_content + "\n"
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

# Generate the documentation content
documentation = process_files_in_directory(r"lib")

# Read template files
with open(filepathes["readme_template"], "r", encoding='utf-8') as file:
    readme_template = file.read()
    
with open(filepathes["description_template"], "r", encoding='utf-8') as file:
    description_template = file.read()
    
with open(filepathes["package_toml_description_template"], "r", encoding='utf-8') as file:
    package_toml_description_template = file.read()

with open(filepathes["version_num"], "r", encoding='utf-8') as file:
    version = file.read()

# Increment version number by 1
version_list = version.split('.')
version_list[-1] = str(int(version_list[-1]) + 1)  # Increment the last part of the version
version = '.'.join(version_list)
# Write the new version number back to the file
with open(filepathes["version_num"], "w", encoding='utf-8') as file:
    file.write(version)
# Print the new version number
print(f"New version number: {version}")

# Build README.md content: readme template + description template + docs
readme_content = readme_template + description_template + documentation

# Build package.toml content: package toml template + """ + package toml description template + description template + docs + """
package_toml_content = f"""
[package]
name = "Iblib"
version = "{version}"
description = \"\"\"package_toml_description_template + description_template + documentation + \"\"\"
"""

# Write the README.md file
with open(r"README.md", "w", encoding='utf-8') as file:
    file.write(readme_content)
    
# Write the package.toml file
with open(r"package.toml", "w", encoding='utf-8') as file:
    file.write(package_toml_content)

print("Generated README.md and package.toml successfully!")
