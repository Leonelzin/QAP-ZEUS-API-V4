import re
import sys

breaks = "\s*\n\s*"
variable = "\{[a-zA-Z][a-zA-Z0-9_]+\}"
invalid_numbers = "\{[0-9]+[a-zA-Z][a-zA-Z0-9_]+\}"
invalid_spaces = "\{[a-zA-Z0-9_]*\s+[a-zA-Z0-9_]*\}"
section = "\n\*\*\*\s+[A-Za-z]*\s*[A-Za-z]+\s+\*\*\*"
variable_section = "\n*** Variables ***"
escape_annotation = "##&"
valid_variable = "{escape_annotation}{variable}{allow_breaks}\${variable}".format(variable = variable, escape_annotation=escape_annotation, allow_breaks=breaks) 
invalid_variable = "{escape_annotation}(({invalid_numbers})|{invalid_spaces})".format(invalid_numbers = invalid_numbers, invalid_spaces = invalid_spaces, escape_annotation=escape_annotation)

escape_attempt = "##" 

def clear(variable_name):
  name = str(re.search(variable, variable_name).group(0))
  return re.sub("[\{\}]+", "", name)

def print_err(msg, err):
  if not err is None:
    print(msg + err, file=sys.stderr)
    raise Exception()

def find_all(a_str, sub):
    start = 0
    while True:
        start = a_str.find(sub, start)
        if start == -1: return
        yield start
        start += len(sub) 

def read_chars_forward(txt, pos, length):
  
  max = (len(txt) - pos)
  max = max if max <= length else length  
  
  return txt[pos: pos + max]

def  show_wrong_variable(result, data):
  attempts = list(find_all(data, escape_attempt))
  valid =  list(map(lambda r : data.find(r) , result))
  return next((read_chars_forward(data, x, 25) for x in attempts if x not in valid), None)


def post_validation(result, processed_result, data):
  if len(result) == 0:
    return
  done = list()
  for d in processed_result:
    done.append(d["alias"])

  first_duplication = next((x for x in done if done.count(x) > 1), None)
  print_err("ERROR: Duplicated Variable--> ", first_duplication)

  sections = list(re.findall(section, data))
  
  pos_variable = data.find(variable_section)

  wrong_location = None
  if pos_variable == -1:
    print_err("No section provided --> ", variable_section)
  else:
    pos_var_sec = sections.index(variable_section)
    if pos_var_sec == len(sections) -1:
      wrong_location = next((x for x in result if data.find(x) < pos_variable), None)
    else:
      next_section = sections[pos_var_sec + 1]
      next_section_pos_on_data = data.find(next_section)
      wrong_location = next((x for x in result if (data.find(x) < pos_variable) or (data.find(x) > next_section_pos_on_data)), None)
    if not wrong_location is None:
      print_err("Annotated variable out of 'Variables' scope --> ", wrong_location)
    attempts = re.findall(escape_attempt, data)
    if len(attempts) > len(result):
      print_err("There are more variable escape attempts than valid variables --> ", show_wrong_variable(result, data))
      
  
def pre_validation(data):
  invalid = re.search(invalid_variable, data)
  if not invalid is None:
    invalid = invalid.group(0)

def extract_variables_from_search(raw):
  raw_variable = re.split(breaks, raw)
  alias = clear(raw_variable[0])
  name = clear(raw_variable[1])
  return {"alias":alias, "name":name}

def extract_variables(file_path):
  if isinstance(file_path, str) and file_path.endswith('.robot'):
    with open(file_path, 'r') as file:
      data = file.read()
    
    pre_validation(data)
    result = re.findall(valid_variable, data)
    processed_result = list(map(extract_variables_from_search , result))
    post_validation(result, processed_result, data)
    return processed_result
  else:
    return None
