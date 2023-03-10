class TestRunnerConfig():
  is_stopped = False

  def __init__(self):
    self.config = {
      'endpoints': {
        'get_cycle_test_endpoint': '/core/v1/cycle-test-automated/by-token/{token}',
        'resport_status_endpoint': '/core/v1/cycle-test-automated/{token}/report-status',
        'update_execution_step': '/core/v1/cycle-test-automated/{token}/execution-status',
        'report_robot_log': '/core/v1/cycle-test-automated/{cycleTestUnitId}/report-log'
      },
      'directory': {
        'reports_directory': '/usr/src/app/'
      }
    }

  def get_directory(self, directory):
    return self.config['directory'][directory]

  def set_specific_config(self, config, value):
    self.config[config] = value
  
  def get_endpoint(self, endpoint):
    return self.config['endpoints'][endpoint]

  def get_execution_situation(self):
    return self.is_stopped
  
  def set_execution_situation(self, situation):
    self.is_stopped = situation