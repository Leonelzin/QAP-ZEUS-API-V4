*** Settings ***
Documentation       Resource responsible for compare the API Response with the expected values, according documentation.
...                 Response should be stored in the variable ${response}
Resource            common_resource.resource


*** Keywords ***
Status Code Should Be As Expected
    Log                               Returned Status: ${RESPONSE.status_code}
    Log                               Expected Status: ${EXPECTED_STATUS_CODE}
    Status Should Be                  ${EXPECTED_STATUS_CODE}      ${RESPONSE}
    ...                               msg=Status code not expected

Headers Should Be As Expected
    Log                                              Returned Headers: ${RESPONSE.headers}
    Log                                              Expected Headers: ${EXPECTED_HEADERS}
    Dictionary Should Contain Sub Dictionary         ${RESPONSE.headers}
    ...                                              ${EXPECTED_HEADERS}
    Dictionary Should Not Contain Key                ${RESPONSE.headers}
    ...                                              Authorization

Body Data Structure Should Be As JSON Schema Rule
    ${JSON_SCHEMA_RESPONSE} =                           Get Variable Value
    ...                                                 ${JSON_SCHEMA_RESPONSE}
    ...                                                 ${JSON_SCHEMA}
    IF  $METHOD == "POST"
        IF  not $HAS_JSON_SCHEMA_RESPONSE
            Body Response Should Be Empty
        END
    END
    IF  str($RESPONSE.text) != ""
        Log                                              JSON Schema: ${JSON_SCHEMA_RESPONSE}
        Log                                              Response body: ${RESPONSE.json()}
        Should Not Be Empty                              ${RESPONSE.json()}
        ...                                              msg=Response should not be empty
        Verify Response Data Structure                   ${JSON_SCHEMA_RESPONSE}
        ...                                              ${RESPONSE.json()}
        All Response Keys Should Be On JSON Schema       ${JSON_SCHEMA_RESPONSE}
        ...                                              ${RESPONSE.json()}
    END

Status Code Should Be "${status_code}"
    Status Should Be                    ${status_code}          ${RESPONSE}
    ...                                 msg=Status code not expected

Body Response Should Be Empty
    Should Be Empty                     ${RESPONSE.text}
    ...                                 msg=Response should be empty

Response Should Contain Error Message "${message}"
    Error Message of ${RESPONSE} Should Contain Item "message" With Value "${message}"

Response Should Inform Error Is In The Field "${ITEM}"
    IF  "level" not in $ITEM
        Error Message of ${RESPONSE} Should Contain Item "fields" With Value "${ITEM}"
    ELSE IF  ${ITEM}[level] == 1
        Error Message of ${RESPONSE} Should Contain Item "fields" With Value "${ITEM}[key]"
    ELSE IF  ${ITEM}[level] == 2
        Error Message of ${RESPONSE} Should Contain Item "fields" With Value "${ITEM}[key].${ITEM}[subkey]"
    END

Response Should Inform That Error Code Is "${code}"
    Error Message of ${RESPONSE} Should Contain Item "code" With Value "${code}"

Error Message of ${RESPONSE} Should Contain Item "${ITEM_KEY}" With Value "${ITEM_VALUE}"
    Should Not Be Empty                 ${RESPONSE.text}
    ...                                 msg=Response should not be empty
    Log Many                            ${RESPONSE.json()}
    Dictionary Should Contain Key       ${RESPONSE.json()}              errors
    ...                                 msg=Response does not contain key "errors"
    ${errors_list} =                    Set Variable                    ${RESPONSE.json()}[errors]
    ${errors_dict} =                    Set Variable                    ${errors_list}[0]
    Dictionary Should Contain Key       ${errors_dict}                  ${ITEM_KEY}
    ...                                 msg=Error does not contain key "${ITEM_KEY}"
    Should Be Equal As Strings          ${errors_dict}[${ITEM_KEY}]     ${ITEM_VALUE}
    ...                                 msg=Error ${ITEM_KEY} not expected

Define ID Attributtes
    Connection With Web Service Is Succeed
    ${id_quantity} =         Evaluate           $URI.count("id}")
    FOR   ${id_count}   IN RANGE   ${id_quantity}
        Send GET Request To Base URL
        Set URI With Attribute ID
        ${id_quantity} =     Evaluate           $URI.count("id}")
    END

Value ${value} Must Have Been Applied To The Key ${ITEM}
    Send GET Request To Created Resource
    Should Not Be Empty               ${RESPONSE.text}
    ...                               msg=Response should not be empty
    ${json_response} =                Set Variable     ${RESPONSE.json()}
    ${is_a_list} =                    Evaluate         isinstance($json_response, list)
    IF  $is_a_list and len($json_response) > 0
        ${json_response} =            Set Variable     ${json_response}[0]
    END
    IF  ${ITEM}[level] == 1
        Should Be Equal As Strings    ${value}         ${json_response}[${ITEM}[key]]
    ELSE IF  ${ITEM}[level] == 2
        Should Be Equal As Strings    ${value}         ${json_response}[${ITEM}[key]][${ITEM}[subkey]]
    END

All Values Must Have Been Applied
    Send GET Request To Created Resource
    Should Not Be Empty               ${RESPONSE.text}
    ...                               msg=Response should not be empty
    ${json_response} =                Set Variable        ${RESPONSE.json()}
    ${response_is_a_list} =           Evaluate            isinstance($json_response, list)
    IF  $response_is_a_list and len($json_response) > 0
        ${json_response} =            Set Variable        ${json_response}[0]
    END
    ${request_is_a_list} =            Evaluate            isinstance($REQUEST_BODY, list)
    IF  $request_is_a_list and len($REQUEST_BODY) > 0
        ${REQUEST_BODY} =             Set Variable        ${REQUEST_BODY}[0]
    END
    Log Many                          ${json_response}
    Log Many                          ${REQUEST_BODY}
    Dictionary Should Contain Sub Dictionary              ${json_response}
    ...                                                   ${REQUEST_BODY}

Identify Current Quantity Of Resources
    Send GET Request And Save Response
    Should Not Be Empty           ${RESPONSE.text}
    ...                           msg=Response should not be empty
    ${CURRENT_QUANTITY} =         Get Length        ${RESPONSE.json()}
    Set Test Variable             ${CURRENT_QUANTITY}

All Recourses Created Are Visible In Response
    Should Not Be Empty                       ${RESPONSE.text}
    ...                                       msg=Response should not be empty
    ${QUANTITY_OF_VISIBLE_RESOURCES} =        Get Length    ${RESPONSE.json()}
    Should Be Equal As Integers               ${QUANTITY_OF_VISIBLE_RESOURCES}
    ...                                       ${LIMIT_OF_RESOURCES}

Only Default Resources Remain
    Send GET Request And Save Response
    ${default_option} =            Create Dictionary     default       ${TRUE}
    IF  str($RESPONSE.text) != ""
        FOR  ${resource}  IN  @{RESPONSE.json()}
            Dictionary Should Contain Sub Dictionary     ${resource}   ${default_option}
        END
    END

Resource Is No Longer Visible
    Send GET Request And Save Response
    Status Should Be          404         ${RESPONSE}
    ...                       msg=Resource should have been deleted

Identify If Endpoint Has a Default Resource
    ${TEST_ID} =                     Identify ID Of Existent Resource
    ${URI} =                         Include ID ${TEST_ID} Into URI ${URI}
    Set Test Variable                ${URI}
    Identify If Resource Is Default

Identify ID Of Existent Resource
    Send GET Request To Base URL
    ${TEST_ID} =                     Check If ${RESPONSE} Has ID Key
    Skip If                          "${TEST_ID}" == "${EMPTY}"
    ...                              msg=Response does not contain resource with valid id
    [Return]                         ${TEST_ID}

Identify If Resource Is Default
    Send GET Request And Save Response
    ${default_option} =              Create Dictionary     default       ${TRUE}
    ${is_default} =                  Run Keyword And Return Status       Dictionary Should Contain Sub Dictionary
    ...                              ${RESPONSE.json()}                  ${default_option}
    Skip If                          ${is_default} == ${FALSE}