*** Settings ***
Documentation    Resources to keywords that interact directly with the API under test.
Resource         common_resource.resource

*** Variables ***
${URI_LOGIN}       /system/sessions


*** Keywords ***
Connection With Web Service Is Succeed
    ${token} =             Get The API Token       ${URI_LOGIN}
    ${headers} =           Set Auth In Request Headers          ${token}
    Create Session         connect_to_dut          ${API}       headers=${headers}

Original Configuration Is Known
    ${original} =          GET On Session         connect_to_dut
                           ...                    ${URI}
    Set Suite Variable     ${ORIGINAL}            ${original.json()}

# GET:
Send GET Request And Save Response
    ${RESPONSE} =          GET On Session         connect_to_dut
                           ...                    ${URI}
                           ...                    timeout=1
                           ...                    expected_status=anything
    Set Test Variable      ${RESPONSE}

Send GET Request Without Authentication
    ${RESPONSE} =          GET                    ${API}${URI}
                           ...                    expected_status=anything
                           ...                    timeout=5
    Set Test Variable      ${RESPONSE}

Send GET Request With Empty Authentication
    ${headers} =           Set Empty Auth In Request Headers
    ${RESPONSE} =          GET                    ${API}${URI}
                           ...                    headers=${headers}
                           ...                    expected_status=anything
                           ...                    timeout=5
    Set Test Variable      ${RESPONSE}

Send GET Request With Wrong Authentication
    ${headers} =           Set Wrong Auth In Request Headers
    ${RESPONSE} =          GET                    ${API}${URI}
                           ...                    headers=${headers}
                           ...                    expected_status=anything
                           ...                    timeout=5
    Set Test Variable      ${RESPONSE}

Send GET Request To Base URL
    ${BASE_URI} =          Remove ID From URI ${URI}
    ${RESPONSE} =          GET On Session         connect_to_dut
                           ...                    ${BASE_URI}
                           ...                    timeout=1
    Set Suite Variable     ${RESPONSE}

Send GET Request To Created Resource
    ${TEST_ID} =               Get Variable Value
    ...                        $TEST_ID               ${EMPTY}
    Log    ${TEST_ID}
    Log    ${JSON_SCHEMA}[type]
    IF  $TEST_ID != "" and $JSON_SCHEMA["type"] == "array"
        ${RESPONSE} =          GET On Session         connect_to_dut
                               ...                    ${URI}/${TEST_ID}
                               ...                    timeout=1
        Set Test Variable      ${RESPONSE}
    ELSE
        Send GET Request And Save Response
    END

# PUT:
Send PUT Request And Save Response
    ${RESPONSE} =          PUT On Session         connect_to_dut
                           ...                    ${URI}
                           ...                    json=${BODY_EXAMPLE}
                           ...                    timeout=1
                           ...                    expected_status=anything
    Set Test Variable      ${REQUEST_BODY}        ${BODY_EXAMPLE}
    Set Test Variable      ${RESPONSE}

Send PUT Request With Body ${CHANGED_BODY}
    ${RESPONSE} =          PUT On Session         connect_to_dut
                           ...                    ${URI}
                           ...                    json=${CHANGED_BODY}
                           ...                    expected_status=anything
                           ...                    timeout=1
    Set Test Variable      ${REQUEST_BODY}        ${CHANGED_BODY}
    Set Test Variable      ${RESPONSE}

Send PUT Request Without Authentication
    ${RESPONSE} =          PUT                    ${API}${URI}
                           ...                    expected_status=anything
                           ...                    json=${BODY_EXAMPLE}
                           ...                    timeout=5

    Set Test Variable      ${RESPONSE}

Send PUT Request With Empty Authentication
    ${headers} =           Set Empty Auth In Request Headers
    ${RESPONSE} =          PUT                    ${API}${URI}
                           ...                    headers=${headers}
                           ...                    expected_status=anything
                           ...                    json=${BODY_EXAMPLE}
                           ...                    timeout=5
    Set Test Variable      ${RESPONSE}

Send PUT Request With Wrong Authentication
    ${headers} =           Set Wrong Auth In Request Headers
    ${RESPONSE} =          PUT                    ${API}${URI}
                           ...                    headers=${headers}
                           ...                    expected_status=anything
                           ...                    json=${BODY_EXAMPLE}
                           ...                    timeout=5
    Set Test Variable      ${RESPONSE}

Send PUT Request Without Key ${KEY}
    ${INCOMPLETE_BODY} =       Set Request Body ${BODY_EXAMPLE} Without ${KEY}
    Send PUT Request With Body ${INCOMPLETE_BODY}

Send PUT Request With Invalid Type ${INVALID_TYPE} On Key ${TARGET_KEY}
    ${NEW_VALUE} =             Set New Value With Type ${INVALID_TYPE}
    ${CHANGED_BODY} =          Set Request Body ${BODY_EXAMPLE} Changing Value Of Key ${TARGET_KEY} To ${NEW_VALUE}
    Send PUT Request With Body ${CHANGED_BODY}

Send PUT Request With Value ${VALUE} On Key ${KEY}
    ${CHANGED_BODY} =          Set Request Body ${BODY_EXAMPLE} Changing Value Of Key ${KEY} To ${VALUE}
    Send PUT Request With Body ${CHANGED_BODY}

# POST:
Send POST Request With Body ${REQUEST_BODY}
    ${RESPONSE} =               POST On Session        connect_to_dut
                                ...                    ${URI}
                                ...                    json=${REQUEST_BODY}
                                ...                    expected_status=anything
                                ...                    timeout=1
    Set Test Variable           ${REQUEST_BODY}
    Set Test Variable           ${RESPONSE}
    Save ID If Existing

Send POST Request And Save Response
    ${REQUEST_BODY} =           Set Request Body ${BODY_EXAMPLE} With Random Values On Unique Fields
    IF  $HAS_MULTIPLE_RESPONSE and $METHOD == "POST"
        ${REQUEST_BODY} =       Set Request Body ${REQUEST_BODY} As A List With One Element
        Set Test Variable       ${EXPECTED_STATUS_CODE}           201
    END
    Send POST Request With Body ${REQUEST_BODY}

Send POST Request Without Authentication
    ${RESPONSE} =          POST                   ${API}${URI}
                           ...                    expected_status=anything
                           ...                    json=${BODY_EXAMPLE}
                           ...                    timeout=5

    Set Test Variable      ${RESPONSE}

Send POST Request With Empty Authentication
    ${headers} =           Set Empty Auth In Request Headers
    ${RESPONSE} =          POST                   ${API}${URI}
                           ...                    headers=${headers}
                           ...                    expected_status=anything
                           ...                    json=${BODY_EXAMPLE}
                           ...                    timeout=5
    Set Test Variable      ${RESPONSE}

Send POST Request With Wrong Authentication
    ${headers} =           Set Wrong Auth In Request Headers
    ${RESPONSE} =          POST                   ${API}${URI}
                           ...                    headers=${headers}
                           ...                    expected_status=anything
                           ...                    json=${BODY_EXAMPLE}
                           ...                    timeout=5
    Set Test Variable      ${RESPONSE}

Send POST Request To Base URL
    ${BASE_URI} =                     Remove ID From URI ${URI}
    ${base_url_body_example} =        Find Example Of Body        ${BASE_URI}   POST
    ${REQUEST_BODY} =                 Set Request Body ${base_url_body_example} With Random Values On Unique Fields
    ${response} =                     POST On Session             connect_to_dut
                                      ...                         ${BASE_URI}
                                      ...                         json=${REQUEST_BODY}
                                      ...                         timeout=1
    Set Suite Variable                ${TEST_ID}                  ${response.json()}[id]

Send POST Request Without Key ${KEY}
    ${REQUEST_BODY} =      Set Request Body ${BODY_EXAMPLE} With Random Values On Unique Fields
    ${INCOMPLETE_BODY} =   Set Request Body ${REQUEST_BODY} Without ${KEY}
    Send POST Request With Body ${INCOMPLETE_BODY}

Send POST Request With Invalid Type ${INVALID_TYPE} On Key ${TARGET_KEY}
    ${REQUEST_BODY} =      Set Request Body ${BODY_EXAMPLE} With Random Values On Unique Fields
    ${NEW_VALUE} =         Set New Value With Type ${INVALID_TYPE}
    ${CHANGED_BODY} =      Set Request Body ${REQUEST_BODY} Changing Value Of Key ${TARGET_KEY} To ${NEW_VALUE}
    Send POST Request With Body ${CHANGED_BODY}

Send POST Request With Value ${VALUE} On Key ${KEY}
    ${REQUEST_BODY} =      Set Request Body ${BODY_EXAMPLE} With Random Values On Unique Fields
    ${CHANGED_BODY} =      Set Request Body ${REQUEST_BODY} Changing Value Of Key ${KEY} To ${VALUE}
    Send POST Request With Body ${CHANGED_BODY}

Create Maximum Of Resources
    FOR  ${resource_quantity}  IN RANGE  1000
        ${REQUEST_BODY} =          Set Request Body ${BODY_EXAMPLE} With Random Values On Unique Fields
        ${request_is_succeed} =    Run Keyword And Return Status
        ...                        POST On Session          connect_to_dut
                                   ...                      ${URI}
                                   ...                      json=${REQUEST_BODY}
                                   ...                      timeout=1
        Exit For Loop If           ${request_is_succeed} == ${FALSE}
    END

Create New Resource And Save URI Value
#    Identify Base URI
    Send POST Request To Base URL
    ${URI} =                       Include ID ${TEST_ID} Into URI ${URI}
    Set Test Variable              ${URI}

# DELETE:
Send DELETE Request And Save Response
    ${RESPONSE} =           DELETE On Session      connect_to_dut
                            ...                    ${URI}
                            ...                    timeout=1
                            ...                    expected_status=anything
    Set Suite Variable      ${RESPONSE}

Send DELETE Request To Base URL
    ${BASE_URI} =           Remove ID From URI ${URI}
    ${RESPONSE} =           DELETE On Session      connect_to_dut
                            ...                    ${BASE_URI}
                            ...                    timeout=1
    Set Suite Variable      ${RESPONSE}

Try To DELETE Created Resource
    Run Keyword And Ignore Error   DELETE On Session      connect_to_dut
                                   ...                    ${URI}/${TEST_ID}
                                   ...                    timeout=1

Back To Original Configuration
    PUT On Session         connect_to_dut         ${URI}
                           ...                    json=${original}

# OTHER:
Get The API Token
    [Arguments]              ${SESSION_URI}
    ${auth_headers} =        Set Login Request Header
    ${auth_body} =           Set Login Request Body
    ${resp} =                POST                          ${API}${SESSION_URI}
    ...                                                    json=${auth_body}
    ...                                                    headers=${auth_headers}
    ${token} =               Get From Dictionary           ${resp.json()}    token
    [Return]                 ${token}

Logout Session
    [Arguments]            ${TOKEN}
    ${response} =          DELETE On Session      connect_to_dut     ${SESSION_URI}/${TOKEN}