from jsonschema import Draft7Validator, draft7_format_checker
from robot.api.deco import keyword


@keyword('Include id ${param_id} into URI ${uri}')
def include_id_into_uri(param_id, uri):
    """
    Find parameter between curly brackets {} and replace by new parameter
    :param param_id: string with a parameter to be placed between {}
    :param uri: string that can contain parameter to be filled
    :return: string containing uri with new parameter
    """
    uri = str(uri)
    if uri.count("{id}") > 0:
        uri_splitted = uri.split("{id}")
        uri_with_id = str(param_id).join(uri_splitted)
        return uri_with_id
    elif uri.count("{") > 0 and uri.count("}") > 0:
        param_init_index = uri.find('{') + 1
        param_end_index = uri.find('}')
        uri_param = uri[param_init_index:param_end_index]
        if uri.count(uri_param) > 0:
            uri_splitted = uri.split('{' + uri_param + '}')
            uri_with_id = str(param_id).join(uri_splitted)
            return uri_with_id
    return uri


@keyword('Remove id from URI ${uri}')
def remove_id_from_uri(uri):
    uri = str(uri)
    if uri.count("{id}") > 0:
        uri_splitted = uri.split("/{id}")
        uri_without_id = uri_splitted[0]
        return uri_without_id
    elif uri.count("{") > 0 and uri.count("}") > 0:
        param_init_index = uri.find('{') + 1
        param_end_index = uri.find('}')
        uri_param = uri[param_init_index:param_end_index]
        if uri.count(uri_param) > 0:
            uri_splitted = uri.split('{' + uri_param + '}')
            uri_without_id = uri_splitted[0]
            return uri_without_id
    return uri


# @keyword('Include parameter ${param} into URI ${uri}')
# def include_param_into_uri(param,uri):
#     """
#     Find parameter between curly brackets {} and replace by new parameter
#     :param param: string with a parameter to be placed between {}
#     :param uri: string that can contain parameter to be filled
#     :return: string containing uri with new parameter
#     """
#     param_init_index = uri.find('{') + 1
#     param_end_index = uri.find('}')
#     uriParam = uri[param_init_index:param_end_index]
#     if uri.count(uriParam) > 0:
#         uriSplited = uri.split('{' + uriParam + '}')
#         uriWithParam = str(param).join(uriSplited)
#         return uriWithParam
#     return uri


@keyword('Verify Response Data Structure')
def verify_response_data_structure(schema, response):
    """
    Check if api response follow the json schema rules
    :param schema: a valid json schema
    :param response: a json with the api response
    :return: error if response is incompatible with json schema
    """
    validator = Draft7Validator(schema=schema,
                                format_checker=draft7_format_checker)
    errors = validator.iter_errors(response)

    error_messages = []
    for error in errors:
        error_paths = list(error.path)
        error_messages.append(f'{error_paths}: {error.message}')
    if len(error_messages) > 0:
        raise Exception(error_messages)


@keyword('All Response Keys Should Be On JSON Schema')
def all_response_keys_should_be_on_json_schema(schema, response):
    """
    Check if api response contains keys that are not documented on json schema
    :param schema: a valid json schema
    :param response: a json with the api response
    :return: error if response contain not documented keys
    """
    out_of_schema_keys = []
    if 'properties' in schema.keys():
        for key, value in response.items():
            if key not in schema['properties'].keys():
                out_of_schema_keys.append(key)
        if len(out_of_schema_keys) > 0:
            raise Exception(f"Keys are not on JSON Schema: {out_of_schema_keys}")

@keyword('Organize Schema As List Of Items')
def organize_schema_as_list_of_items(schema):
    info_list = []
    if schema["type"] == "array" and "items" in schema:
        schema = schema["items"]
        if isinstance(schema, list):
            schema = schema[0]
    if "properties" in schema:
        for key, value in schema['properties'].items():
            info = {}
            info["key"] = key
            info["level"] = 1
            info["is_required"] = False
            if "required" in schema:
                if key in schema["required"]:
                    info["is_required"] = True
            for parameter, parameter_value in value.items():
                if parameter not in ["properties", "required"]:
                    info[parameter] = value[parameter]
                if "type" not in value and "enum" in value:
                    info["type"] = "enum"
            if "type" in value and value["type"] == "object":
                if "properties" in value:
                    for subkey, subvalue in value["properties"].items():
                        subkey_info = {}
                        subkey_info["level"] = 2
                        subkey_info["key"] = key
                        subkey_info["subkey"] = subkey
                        subkey_info["is_required"] = False
                        if "required" in value:
                            if subkey in value["required"]:
                                subkey_info["is_required"] = True
                        for sub_parameter, sub_parameter_value in subvalue.items():
                            if sub_parameter not in ["properties", "required"]:
                                subkey_info[sub_parameter] = subvalue[sub_parameter]
                            if "type" not in subvalue and "enum" in subvalue:
                                subkey_info["type"] = "enum"
                        info_list.append(subkey_info)
            info_list.append(info)
    return info_list


@keyword("Check if ${response} has ID key")
def check_response_has_id_key(response):
    response_json = response.json()
    if len(response_json) == 0:
        return ""
    if isinstance(response_json, list):
        response_json = response_json[0]
    if "id" in response_json:
        return response_json["id"]
    else:
        return ""


@keyword('Make Invalid Json Data ')
def make_invalid_json_data(body):
    body = str(body)
    invalid_body_list = []
    if body.count("{") > 0:
        invalid_body = body.split("{")
        invalid_body = "[".join(invalid_body)
        invalid_body_list.append(invalid_body)
    if body.count(",") > 0:
        invalid_body = body.split(",")
        invalid_body = ".".join(invalid_body)
        invalid_body_list.append(invalid_body)
    if body.count("[") > 0:
        invalid_body = body.split("[")
        invalid_body = "".join(invalid_body)
        invalid_body_list.append(invalid_body)
    return invalid_body_list
