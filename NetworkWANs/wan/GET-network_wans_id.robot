*** Settings ***
Documentation       Suite responsible for Retrieve wan settings.
Resource            ../../../../resources/common_resource.resource
Force Tags          robot:continue-on-failure
Suite Setup         Run Keywords         Get API Reference Documentation   ${URI}  ${METHOD}
...                 AND                  Define ID Attributtes


*** Variables ***
${URI}       /network/wans/{id}
${METHOD}    GET


*** Test Case ***
GET is Succeed
    Given Connection With Web Service Is Succeed
    When Send GET Request And Save Response
    Then Status Code Should Be As Expected
    And Headers Should Be As Expected
    And Body Data Structure Should Be As JSON Schema Rule

GET Without Authentication
    When Send GET Request Without Authentication
    Then Status Code Should Be "401"

GET With Empty Authentication
    When Send GET Request With Empty Authentication
    Then Status Code Should Be "401"

GET With Wrong Authentication
    When Send GET Request With Empty Authentication
    Then Status Code Should Be "401"
