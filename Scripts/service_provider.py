######### IMPORTS #########
from subprocess import call
from config.service_config import ServiceConfig

import requests
import os
import sys
import logging
import logging.config
import robot
import json
import docker

######### Configurations #########
_service_config = ServiceConfig()

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

class ServiceProvider:
    ######### VARIABLES #########

    def __init__(self, token, base_url):
        # Initializing service list
        self._services_to_up = None

        # Initializing docker client
        self._docker_client = docker.from_env()

        # Initializing list to manage services
        self._service_containers = []
        
        # Verifying if there is one argument at least
        if (token == None or base_url == None or token.isspace() or base_url.isspace()):
            logger.error('There\'s no sufficient parameters to execute a service')
            logger.info('Exiting service provider ...')
            sys.exit()

        # Getting token and base_url variables
        self._token = token
        self._base_url = base_url
    


    ######## FUNCTIONS ##########

    def _parse_response_to_json(self, response):
        try:
            return response.json()
        except:
            logger.error('Error while get json response')
            logger.error('Status code: ' + response.status_code)

    def _get_full_url_get_services_by_token(self):
        return self._base_url + _service_config.get_endpoint('get_services_by_token').replace("{token}", self._token)

    def remove_all_services(self):
        logger.info("Removing all services")
        for container in self._service_containers:
            container.remove(force=True)

    def _get_services_by_token_and_provide(self):

        # Getting service to run
        self._services_to_up = self._parse_response_to_json(requests.get(url=self._get_full_url_get_services_by_token()))

        logger.info('Checking if exists services to up')
        if (isinstance(self._services_to_up, list) and len(self._services_to_up) > 0):
            logger.info('There is services to up')
            for service in self._services_to_up:
                logger.info('Pulling image')
                self._docker_client.images.pull(
                    service['version']['link'], 
                    auth_config={'username': service['version']['credentialUsername'], 'password': service['version']['credentialPassword']}
                )
                
                logger.info('Parsing enviroments variables')
                environments = self._mount_service_environments_parameters(service)
                self._run_services(service, environments)
                
        else:
            logger.info('There isnt services to be deployed')
            pass               

    def _mount_service_environments_parameters(self, service, environments={}):
        for varenv in service['version']['parameters']:
            environments[varenv['key']] = varenv['value']
        return environments

    def _run_services(self, service, environments):
        logger.info('Starting service ...')
        container = self._docker_client.containers.run(service['version']['link'], 
                    environment=environments, 
                    privileged=True, 
                    network_mode='host', 
                    init=True, 
                    detach=True, 
                    auto_remove=True
                )

        self._service_containers.append(container)

        logger.info('Service started!')

    def provide(self):
        self._get_services_by_token_and_provide()

    def remove_services(self):
        self.remove_all_services()
