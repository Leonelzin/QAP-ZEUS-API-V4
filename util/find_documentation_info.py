import json
import requests
from robot.api.deco import keyword
from api_variables import API_DOC_URL


@keyword('Find API Example')
def find_api_example(uri, method):
    api_info = requests.get(API_DOC_URL)
    resource_groups = api_info.json()['resourceGroups']
    example_found = False
    for group in resource_groups:
        for resource in group['resources']:
            if resource['uriTemplate'] == uri:
                for action in resource['actions']:
                    if action['method'] == method:
                        example_found = True
                        example = action['examples'][0]
                        return example
    if not example_found:
        raise Exception(f'method {method} not available to {uri}')


@keyword('Find Json Schema')
def find_json_schema(uri, method):
    if method == 'GET':
        example = find_response_example(uri, method)
    else:
        example = find_request_example(uri, method)
    if example['schema'] == '':
        raise Exception(f'schema not found to {uri}')
    else:
        full_schema = example['schema']
        schema = json.loads(full_schema)
    return schema


@keyword('Find Response Json Schema')
def find_response_json_schema(uri, method):
    example = find_response_example(uri, method)
    if example['schema'] == '':
        raise Exception(f'schema not found to {uri}')
    else:
        full_schema = example['schema']
        schema = json.loads(full_schema)
    return schema


@keyword('Find Request Json Schema')
def find_request_json_schema(uri, method):
    example = find_request_example(uri, method)
    if example['schema'] == '':
        raise Exception(f'schema not found to {uri}')
    else:
        full_schema = example['schema']
        schema = json.loads(full_schema)
    return schema


@keyword('Find Response Example')
def find_response_example(uri, method):
    example = find_api_example(uri, method)
    response_example = example['responses'][0]
    if response_example['body'] == '' and len(example['responses']) > 1:
        response_example = example['responses'][1]
    return response_example


@keyword('Find Request Example')
def find_request_example(uri, method):
    example = find_api_example(uri, method)
    request_example = example['requests'][0]
    return request_example


@keyword('Find Desirable Request Headers')
def find_desirable_request_headers(uri, method):
    request_example = find_request_example(uri, method)
    desirable_headers = request_example['headers']
    return desirable_headers


@keyword('Find Desirable Response Headers')
def find_desirable_response_headers(uri, method):
    response_example = find_response_example(uri, method)
    desirable_headers = response_example['headers']
    return desirable_headers


@keyword('Find Desirable Status Code')
def find_desirable_status_code(uri, method):
    response_example = find_response_example(uri, method)
    desirable_status = response_example['status']
    return desirable_status


@keyword('Find Example of Body')
def find_example_of_body(uri, method):
    if method == 'GET':
        example = find_response_example(uri, method)
    else:
        example = find_request_example(uri, method)
    if example['body'] == '':
        raise Exception(f'example of body not found to {uri}')
    else:
        body_example = json.loads(example['body'])
    return body_example


@keyword('Find Post With More Than One Response')
def find_post_with_more_than_one_response():
    api_info = requests.get(API_DOC_URL)
    resource_groups = api_info.json()['resourceGroups']
    more_than_one_list = []
    for group in resource_groups:
        for resource in group['resources']:
            for action in resource['actions']:
                if action['method'] == 'POST':
                    for example in action['examples']:
                        quant_response = 0
                        for response in example['responses']:
                            quant_response += 1
                        if quant_response > 1:
                            more_than_one_list.append(resource['uriTemplate'])
    return more_than_one_list


@keyword('Find Post With Just One Response')
def find_post_with_just_one_response():
    api_info = requests.get(API_DOC_URL)
    resource_groups = api_info.json()['resourceGroups']
    just_one_list = []
    for group in resource_groups:
        for resource in group['resources']:
            for action in resource['actions']:
                if action['method'] == 'POST':
                    for example in action['examples']:
                        quant_response = 0
                        for response in example['responses']:
                            quant_response += 1
                        if quant_response == 1:
                            just_one_list.append(resource['uriTemplate'])
    return just_one_list


@keyword("Get URI with ID from ${URI}")
def get_uri_with_id(uri):
    possible_uris = []
    api_info = requests.get(API_DOC_URL)
    resource_groups = api_info.json()['resourceGroups']
    for group in resource_groups:
        for resource in group['resources']:
            if (uri + "/{") in resource['uriTemplate']:
                possible_uris.append(resource['uriTemplate'])
    if len(possible_uris) > 0:
        uri_with_id = possible_uris[0]
        if len(possible_uris) > 1:
            for item in possible_uris:
                if len(item) < len(uri_with_id):
                    uri_with_id = item
        return uri_with_id


@keyword("Find Methods Available To Endpoint ${URI}")
def find_methods_available_to_endpoint(uri):
    methods = []
    api_info = requests.get(API_DOC_URL)
    resource_groups = api_info.json()['resourceGroups']
    for group in resource_groups:
        for resource in group['resources']:
            if uri == resource["uriTemplate"]:
                for action in resource['actions']:
                    methods.append(action["method"])
    return methods
