class ServiceConfig():
  is_stopped = False

  def __init__(self):
    self.config = {
      'endpoints': {
        'get_services_by_token': '/core/v1/services/by-token/{token}',
      }
    }

  def get_endpoint(self, endpoint):
    return self.config['endpoints'][endpoint]
