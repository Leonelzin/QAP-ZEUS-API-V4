*** Settings ***
Documentation       Template to be used in endpoints that accept DELETE method in requests.
Resource            ../../../../resources/common_resource.resource
Force Tags          robot:continue-on-failure
Suite Setup         Run Keywords         Get API Reference Documentation   ${URI}  ${METHOD}
...                 AND                  Check API has multiple responses
...                 AND                  Identify If Response Has JSON Schema


*** Variables ***
${URI}       /interfaces/wifi/ssids/id/acl
${METHOD}    DELETE


*** Test Case ***
DELETE Multiple Resources
    Given Connection With Web Service Is Succeed
    And Identify If Endpoint Supports Multiple Resources
    And Define ID Attributtes
    And Create Maximum Of Resources
    When Send DELETE Request And Save Response
    Then Status Code Should Be As Expected
    And Headers Should Be As Expected
    And Only Default Resources Remain

DELETE Created Resource
    Given Connection With Web Service Is Succeed
    And Identify If Endpoint Is From Specific Resource
    And Create New Resource And Save URI Value
    When Send DELETE Request And Save Response
    Then Status Code Should Be As Expected
    And Headers Should Be As Expected
    And Resource Is No Longer Visible

DELETE Default Resource
    Given Connection With Web Service Is Succeed
    And Identify If Endpoint Is From Specific Resource
    And Identify If Endpoint Has a Default Resource
    When Send DELETE Request And Save Response
    Then Status Code Should Be "400"
#    And Response Should Contain Error Message "${message}"


*** Keywords ***
