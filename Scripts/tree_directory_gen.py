import os
import json
from variable_extractor import extract_variables

def check_in_file(my_file, my_string):
    print(my_file)
    with open(my_file) as f:
        try:
            return my_string in f.read()
        except:
            return False

def validate_file(file_name):
    return file_name.endswith('.robot')

def validate_folder(folder_name):
    return folder_name == 'Resources'

def path_to_directory(path, from_file=None):
    path_name = os.path.basename(path)

    if ((not os.path.isdir(path) and not validate_file(path_name)) or validate_folder(path_name)):
        return None

    if (path_name.endswith('.')):
        path_name = 'root'

    directory = {
        'id': path,
        'name': path_name,
        'variables': extract_variables(path)
    }

    if (os.path.isdir(path)):
        directory['children'] = []

        paths = [os.path.join(path, x) for x in os.listdir(path)]

        for path in paths:
            c = path_to_directory(path, from_file)

            if c is not None:
                directory['children'].append(c)

        if not directory['children']:
            return None
    else:
        if from_file is not None and not check_in_file(path, from_file):
            return None

    return directory

if __name__ == '__main__':
    with open('./directory_tree.json', 'w') as outfile:
        json.dump(path_to_directory('./src/tests'), outfile, indent=2)
