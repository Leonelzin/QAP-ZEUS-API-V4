#Listener

from dateutil import tz
from dateutil.parser import parse
from dateutil.utils import default_tzinfo
from config.test_runner_config import TestRunnerConfig

import time
import json
import requests
import sys
import os
import logging
import logging.config

  ## getting the base_path by location of this file
_base_file_path = os.path.dirname(os.path.realpath(__file__))

  ## Getting root path of this project
_root_path = os.getcwd()

  ## Getting path config log file
_config_log_file_path = os.path.join(_base_file_path, 'config', 'run_tests_log.conf')
logging.config.fileConfig(_config_log_file_path)

logger = logging.getLogger('defaultLogger')

class TestRunnerListener: 

  ROBOT_LISTENER_API_VERSION = 2
  STRING_ROBOT_TIME_FORMAT = '%Y%m%d %H:%M:%S.%f'
  FAILED_STATUS_KEYWORD = 'FAIL'
  PENDING_STATUS_KEYWORD = 'PENDING'

  def __init__(self, test_info, runner_config):
    self.test_info = test_info
    self.runner_config = runner_config

    self.cycle_tests_steps = []
    self.file_name = ''
  
  def _to_localdatetime(self, string_time):
    to_zone = tz.tzlocal()
    return default_tzinfo(parse(string_time), to_zone)

  def _parse_to_info_dto(self, name, suite_attrs):
    return {
      'cycleTestUnitId': self.test_info['id'],
      'token':self.test_info['token'],
      'longName': self.file_name,
      'scenarioName': name,
      'startTime': self._to_localdatetime(suite_attrs['starttime']).isoformat(),
      'endTime': self._to_localdatetime(suite_attrs['endtime']).isoformat(),
      'elapsedTime': suite_attrs['elapsedtime'],
      'status': suite_attrs['status'],
      'message': suite_attrs['message'],
      'cycleTestUnitSteps': self.cycle_tests_steps,
      'documentation': suite_attrs['doc']
    }
  
  def _parse_to_info_step_dto(self, keyword_attrs):
    return {
      'status': keyword_attrs['status'],
      'name': keyword_attrs['kwname']
    }

  def _report_test_info(self, name, suite_attrs):
    test_info_dto = self._parse_to_info_dto(name, suite_attrs)
    headers = {'Content-type': 'application/json'}
    response = requests.post(url = self.test_info['report_url'], headers = headers, data = json.dumps(test_info_dto))

    execution = response.json()  
    self.runner_config.set_execution_situation(execution['isStopped'])

    print("Response code: " + str(response.status_code))

  def start_suite(self, name, attrs):
    self.file_name = attrs['source'].split('/').pop()

  def end_test(self, name, attrs):
    self._report_test_info(name, attrs)

  def end_keyword(self, name, attrs):
    # Here we manipulate the step list
    # If exists a 'FAIL' keyword so we change the status of the current keyword to 'PENDING'
    if (attrs['libname'] == ''):
      test_step = self._parse_to_info_step_dto(attrs)
      failed_step = next((step for step in self.cycle_tests_steps if step['status'] == self.FAILED_STATUS_KEYWORD), None)

      if failed_step != None :
        test_step['status'] = self.PENDING_STATUS_KEYWORD
    
      self.cycle_tests_steps.append(test_step)