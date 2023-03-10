######### IMPORTS #########
from subprocess import call
from test_runner_listener import TestRunnerListener
from config.test_runner_config import TestRunnerConfig
from service_provider import ServiceProvider

import requests
import os
import sys
import logging
import logging.config
import robot
import json

######### Configurations #########

_runner_config = TestRunnerConfig()
_service_provider = None

# getting the base_path by location of this file
_base_file_path = os.path.dirname(os.path.realpath(__file__))

# Getting root path of this project
_root_path = os.getcwd()

# Getting path config log file
_config_log_file_path = os.path.join(
    _base_file_path, 'config', 'run_tests_log.conf')

# Loadding config log file
logging.config.fileConfig(_config_log_file_path)

# Initializing logger
logger = logging.getLogger('defaultLogger')

######### VARIABLES #########

#     Collecting arguments

# Verifying if there is one argument at least
if (len(sys.argv) <= 1):
    logger.error('You must give 1 (the token) argument at least')
    logger.info('Exiting program ...')
    sys.exit()
else:
    _token, _base_url = None, None

    # Checking all parameters passed
    if (len(sys.argv) >= 3):
        logger.info('Seems that all parameters was passed')
        _token = sys.argv[1]
        _base_url = sys.argv[2]

        # Configuring the fileLogName to be the token passed
        _logFileHandler = logging.FileHandler(
            filename=_token + '.log', mode='a')
        _logFileHandler.setFormatter(logging.Formatter(
            '[%(asctime)s] [%(levelname)8s] - %(message)s (%(filename)s:%(lineno)s)'))
        logger.addHandler(_logFileHandler)
        logger.info('token: ' + _token + ' base_url: ' + _base_url)
    else:
        logger.error('There\'s no sufficient parameters')
        logger.info('Exiting program ...')
        sys.exit()


######### FUNCTIONS #########
def get_full_url_report():
    return _base_url + _runner_config.get_endpoint('resport_status_endpoint').replace("{token}", _token)


def get_test_conf(test):
    return {
        'id': test['id'],
        'base_url': _base_url,
        'token': _token,
        'file_name': test['test'],
        'report_url': get_full_url_report()
    }


def get_tests_info(token, base_url='localhost:9000'):
    _full_url = base_url + \
        _runner_config.get_endpoint(
            'get_cycle_test_endpoint').replace("{token}", token)
    response = requests.get(url=_full_url)
    logger.error('Trying to get tests Info on api:   ' + _full_url)
    try:
        return response.json()
    except:
        logger.error('Error while get json response')
        logger.error('Status code: ' + response.status_code)


def get_listener(test):
    return TestRunnerListener(get_test_conf(test), _runner_config)

def get_service_provider(token, base_url):
    global _service_provider
    if (_service_provider is None):
        _service_provider = ServiceProvider(token, base_url)
    
    return _service_provider


def format_test_path(test):
    test_path = json.loads(test['test'])['id']
    test_path = test_path.replace(".\\", "")
    return test_path.replace("\\", "/")


def _report_test_info_error(dto_error_info):
    headers = {'Content-type': 'application/json'}
    response = requests.post(url=get_full_url_report(
    ), headers=headers, data=json.dumps(dto_error_info))
    logger.info("Error Reported - Response code: " + str(response.status_code))


def execute_tests(test_plan_data, base_url):
    logger.info('Executing tests for token: ' + test_plan_data['token'])

    if (test_plan_data['isStopped'] == False):
        for test in test_plan_data['tests']:
            test_path = format_test_path(test)

            logger.info('Trying to run tests in on this file: ' + test_path)
            full_path = os.path.join(_root_path, test_path)

            if (os.path.exists(full_path)):
                for parameter in test['parameters']:
                    logger.info(parameter)
                robot.run(
                    full_path, variable=test['parameters'], listener=get_listener(test))
                get_robot_log_content(test['id'], base_url)
                if (_runner_config.get_execution_situation() == True):
                    break
                
                logger.info('Unit Test finished!')
            else:
                logger.info('Error while try execute test. File or directory not found!')
                dto_error_info = {
                    'cycleTestUnitId': test['id'],
                    'token': _token,
                    'longName': test_path,
                    'elapsedTime': 0,
                    'status': 'FAIL',
                    'message': 'File or directory to execute does not exist ' + test_path
                }
                _report_test_info_error(dto_error_info)

    logger.info('Tests finished!')

def get_robot_log_content(cycle_test_unit_id, base_url):
    headers = {'Content-Type': 'application/json'}
    log_directory = _runner_config.get_directory('reports_directory') + 'log.html'
    
    f = open(log_directory)
    stream_file = f.read()
    f.close()

    file_raw = {
        'raw': stream_file
    }

    _full_url = base_url + _runner_config.get_endpoint('report_robot_log').replace("{cycleTestUnitId}", str(cycle_test_unit_id))

    logger.info('Sending robot log html!')
    requests.post(url=_full_url, headers=headers, data=json.dumps(file_raw))
    logger.info('Robot log send result')


def set_test_log_step(token, base_url):
    headers = {'Content-type': 'application/json'}
    execution_step = {
        'status': 'TEST_LOG'
    }

    _full_url = base_url + \
        _runner_config.get_endpoint(
            'update_execution_step').replace("{token}", token)

    requests.patch(url=_full_url, headers=headers,
                   data=json.dumps(execution_step))
    logger.info('set_test_log_step response')

def run_services_if_needed(test_plan_data):
    logger.info('Service provider called')
    get_service_provider(test_plan_data['token'], _base_url).provide()

def remove_services_if_needed():
    logger.info('Removing all services')
    get_service_provider(None, None).remove_services()


###### Main execution ######
def main():
    test_plan_data = get_tests_info(_token, _base_url)
    run_services_if_needed(test_plan_data)
    set_test_log_step(_token, _base_url)
    execute_tests(test_plan_data, _base_url)
    remove_services_if_needed()

main()
