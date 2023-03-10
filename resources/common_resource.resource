*** Settings ***
Resource            send_requests_to_api.resource
Resource            api_response_analysis.resource
Resource            documentation_analysis.resource
Resource            configure_request_data.resource

Library             Collections
Library             RequestsLibrary
Library             FakerLibrary
Library             ../util/api_service.py
Library             ../util/find_documentation_info.py


*** Variables ***
##&{MODEL}
${MODEL}
${MODEL__API}
${MODEL__ID}
${MODEL__MGMT_IPV4_ADDRESS}

${MODEL__USER}                 admin
${MODEL__PASSWORD}             lockzeus



#${API}       ${MODEL__MGMT_IPV4_ADDRESS}     #QAP Execution
${API}       http://192.168.0.10/cgi-bin/api/v4        #Local execution