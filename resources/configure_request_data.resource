*** Settings ***
Documentation    Resource resposible to make adjusts in data that will be used on requests.
Resource         common_resource.resource

*** Keywords ***
# Configure Headers:
Set Auth In Request Headers
    [Arguments]                ${TOKEN}
    ${headers} =               Set Variable                     ${REQUIRED_HEADERS}
    ${header_contain_auth} =   Run Keyword And Return Status    Dictionary Should Contain Key
                               ...                              ${headers}      Authorization
    IF  ${header_contain_auth}
        Set To Dictionary      ${headers}                       Authorization=Token: ${TOKEN}
    ELSE
        Log                    ATTENTION! Endpoint do not use authentication on headers
        ...                    level=WARN
    END
    [Return]                   ${headers}

Set Empty Auth In Request Headers
    ${headers} =               Set Variable               ${REQUIRED_HEADERS}
    Set To Dictionary          ${headers}                 Authorization=${EMPTY}
    [Return]                   ${headers}

Set Wrong Auth In Request Headers
    ${headers} =               Set Variable               ${REQUIRED_HEADERS}
    Set To Dictionary          ${headers}                 Authorization=Token thisIsAWrongToken
    [Return]                   ${headers}

Set Login Request Header
    ${auth_header} =           Create Dictionary          content-type=application/json
    [Return]                   ${auth_header}

# Configure Body:
Set Login Request Body
    ${auth_body} =             Create Dictionary          login=${MODEL__USER}
    ...                                                   password=${MODEL__PASSWORD}
    [Return]                   ${auth_body}

Set Request Body ${BODY} Without ${ITEM}
    ${incomplete_body} =             Copy Dictionary          ${BODY}          deepcopy=True
    ${is_a_list} =                   Evaluate                 isinstance($BODY_EXAMPLE, list)
    IF  ${is_a_list}
        ${incomplete_body} =         Set Variable             ${incomplete_body}[0]
    END
    IF   ${ITEM}[level] == 1
        Remove From Dictionary       ${incomplete_body}       ${ITEM}[key]
    ELSE IF   ${ITEM}[level] == 2
        ${NEW_SUB_DICT} =            Copy Dictionary          ${incomplete_body}[${ITEM}[key]]
        Remove From Dictionary       ${NEW_SUB_DICT}          ${ITEM}[subkey]
        Set To Dictionary            ${incomplete_body}
        ...                          ${ITEM}[key]             ${NEW_SUB_DICT}
    END
    IF  ${is_a_list}
        ${incomplete_body} =         Create List              ${incomplete_body}
    END
    [Return]                         ${incomplete_body}

Set Request Body ${BODY} Changing Value Of Key ${ITEM} To ${NEW_VALUE}
    ${NEW_BODY_EXAMPLE} =            Copy Dictionary          ${BODY}              deepcopy=True
    ${is_a_list} =                   Evaluate                 isinstance($NEW_BODY_EXAMPLE, list)
    IF  ${is_a_list}
        ${NEW_BODY_EXAMPLE} =        Set Variable             ${NEW_BODY_EXAMPLE}[0]
    END
    IF   ${ITEM}[level] == 1
        Remove From Dictionary       ${NEW_BODY_EXAMPLE}      ${ITEM}[key]
        Set To Dictionary            ${NEW_BODY_EXAMPLE}
        ...                          ${ITEM}[key]             ${NEW_VALUE}
    ELSE IF   ${ITEM}[level] == 2
        ${NEW_SUB_DICT} =            Copy Dictionary          ${NEW_BODY_EXAMPLE}[${ITEM}[key]]
        Remove From Dictionary       ${NEW_SUB_DICT}          ${ITEM}[subkey]
        Set To Dictionary            ${NEW_SUB_DICT}
        ...                          ${ITEM}[subkey]          ${NEW_VALUE}
        Set To Dictionary            ${NEW_BODY_EXAMPLE}
        ...                          ${ITEM}[key]             ${NEW_SUB_DICT}
    END
    IF  ${is_a_list}
        ${NEW_BODY_EXAMPLE} =        Create List              ${NEW_BODY_EXAMPLE}
    END
    [Return]                         ${NEW_BODY_EXAMPLE}

Set Request Body ${BODY} With Random Values On Unique Fields
    ${NEW_BODY_EXAMPLE} =             Copy Dictionary   ${BODY}              deepcopy=True
    ${is_a_list} =                    Evaluate          isinstance($NEW_BODY_EXAMPLE, list)
    IF  ${is_a_list}
        ${INNER_BODY} =               Set Variable      ${NEW_BODY_EXAMPLE}[0]
    ELSE
        ${INNER_BODY} =               Copy Dictionary   ${NEW_BODY_EXAMPLE}
    END
    IF  "name" in $INNER_BODY
        ${name} =                     FakerLibrary.Pystr
        ...                           min_chars=1       max_chars=50
        Set To Dictionary             ${INNER_BODY}     name       ${name}
    ELSE IF  "ssid" in $INNER_BODY
        ${ssid} =                     FakerLibrary.Pystr
        ...                           min_chars=1       max_chars=32
        Set To Dictionary             ${INNER_BODY}     ssid       ${ssid}
    ELSE IF  "mac" in $INNER_BODY
        ${mac} =                      FakerLibrary.Mac Address
        Set To Dictionary             ${INNER_BODY}     mac        ${mac}
    END
    IF  "login" in $INNER_BODY
        ${login} =                    FakerLibrary.User Name
        Set To Dictionary             ${INNER_BODY}     login   ${login}
    END
    IF  "password" in $INNER_BODY
        ${password} =                 FakerLibrary.Password
        ...                           length=12         special_chars=${FALSE}
        Set To Dictionary             ${INNER_BODY}     password   ${password}.
    END
    IF  ${is_a_list}
        ${NEW_BODY_EXAMPLE} =         Create List       ${INNER_BODY}
    ELSE
        ${NEW_BODY_EXAMPLE} =         Set Variable      ${INNER_BODY}
    END
    [Return]                          ${NEW_BODY_EXAMPLE}

Set Request Body ${BODY} As A List With One Element
    ${NEW_BODY_EXAMPLE} =         Copy Dictionary      ${BODY}          deepcopy=True
    ${is_a_list} =                Evaluate             isinstance($BODY_EXAMPLE, list)
    IF  ${is_a_list}
        ${INNER_BODY} =           Set Variable         ${NEW_BODY_EXAMPLE}[0]
        ${NEW_BODY_EXAMPLE} =     Create List          ${INNER_BODY}
    ELSE
        ${NEW_BODY_EXAMPLE} =     Create List          ${NEW_BODY_EXAMPLE}
    END
    [Return]                      ${NEW_BODY_EXAMPLE}

Set Request Body ${BODY} With One Object Body
    ${NEW_BODY_EXAMPLE} =          Copy Dictionary      ${BODY}          deepcopy=True
    ${is_a_list} =                 Evaluate             isinstance($BODY_EXAMPLE, list)
    IF  $is_a_list
        ${NEW_BODY_EXAMPLE} =      Set Variable         ${NEW_BODY_EXAMPLE}[0]
    END
    [Return]                       ${NEW_BODY_EXAMPLE}

# Presets:
Identify Base URI
    ${BASE_URI} =                Remove ID From URI ${URI}
    Set Suite Variable           ${BASE_URI}

Set URI With Attribute ID
    ${TEST_ID} =                              Check If ${RESPONSE} Has ID Key
    Set Suite Variable                        ${TEST_ID}
    IF  "${TEST_ID}" == "${EMPTY}"
        Send POST Request To Base URL
        IF  "${TEST_ID}" == "${EMPTY}"
            Send GET Request To Base URL
            ${TEST_ID} =                      Check If ${RESPONSE} Has ID Key
        END
    END
    ${URI} =                                  Include ID ${TEST_ID} Into URI ${URI}
    Set Suite Variable                        ${URI}

Save ID If Existing
    IF  ${HAS_JSON_SCHEMA_RESPONSE}
        Should Not Be Empty             ${RESPONSE.text}
        ...                             msg=Request should have response body
        ${json_response} =              Set Variable      ${response.json()}
        ${is_a_list} =                  Evaluate          isinstance($json_response, list)
        IF  ${is_a_list}
            ${json_response} =          Set Variable      ${json_response}[0]
        END
        IF  "id" in $json_response
            Set Test Variable           ${TEST_ID}        ${json_response}[id]
        ELSE
            Set Test Variable           ${TEST_ID}        ${EMPTY}
        END
    ELSE
        Set Test Variable               ${TEST_ID}        ${EMPTY}
    END

Set New Value With Type ${TYPE}
    IF  "${TYPE}" == "string"
        ${NEW_VALUE} =      FakerLibrary.Pystr
        ...                 min_chars=8   max_chars=8
    END
    IF  "${TYPE}" == "number"
        ${NEW_VALUE} =      FakerLibrary.Pyint
        ...                 min_value=1   max_value=100
    END
    IF  "${TYPE}" == "boolean"
        ${NEW_VALUE} =      FakerLibrary.Pybool
    END
    IF  "${TYPE}" == "array"
        ${NEW_VALUE} =      FakerLibrary.Pylist
        ...                 nb_elements=3   value_types=['str']
    END
    IF  "${TYPE}" == "object"
        ${NEW_VALUE} =      FakerLibrary.Pydict
        ...                 nb_elements=3   value_types=['str']
    END
    [Return]                ${NEW_VALUE}

Remove Corret Type ${CORRECT_TYPE} From Wrong Type List
    ${WRONG_TYPES} =                   Create List   string   number   boolean   array   object
    IF   $CORRECT_TYPE in $WRONG_TYPES
        Remove Values From List        ${WRONG_TYPES}     ${CORRECT_TYPE}
    END
    IF   $CORRECT_TYPE in ["enum", "integer"]
        Remove Values From List        ${WRONG_TYPES}     number
    END
    Set Test Variable                  ${WRONG_TYPES}

Identify Current And Opposite Boolean Values Of Key ${ITEM}
    Send GET Request And Save Response
    ${json_response} =              Set Variable      ${response.json()}
    ${is_a_list} =                  Evaluate          isinstance($json_response, list)
    IF  ${is_a_list}
        ${json_response} =          Set Variable      ${json_response}[0]
    END
    IF  ${ITEM}[level] == 1
        ${ORIGINAL_VALUE} =         Set Variable      ${json_response}[${ITEM}[key]]
    ELSE IF   ${ITEM}[level] == 2
        ${ORIGINAL_VALUE} =         Set Variable      ${json_response}[${ITEM}[key]][${ITEM}[subkey]]
    END
     ${NEW_VALUE} =              Evaluate              not $ORIGINAL_VALUE
    Set Test Variable           ${ORIGINAL_VALUE}
    Set Test Variable           ${NEW_VALUE}

Set A List With Invalid Json Data
    ${INVALID_JSON_LIST} =   Make Invalid Json Data   ${BODY_EXAMPLE}
    Set Test Variable        ${INVALID_JSON_LIST}

Define New Value With Quantity Of Characters Equal ${QUANT}
    ${NEW_VALUE} =           FakerLibrary.Pystr
    ...                      min_chars=${QUANT}   max_chars=${QUANT}
    Set Test Variable        ${NEW_VALUE}

Define New Value With Quantity Of Characters Greater Than ${QUANT}
    ${QUANT} =               Evaluate             int($QUANT)+1
    ${NEW_VALUE} =           FakerLibrary.Pystr
    ...                      min_chars=${QUANT}   max_chars=${QUANT}
    Set Test Variable        ${NEW_VALUE}

Define New Value With Quantity Of Characters Less Than ${QUANT}
    ${QUANT} =               Evaluate             int($QUANT)-1
    ${NEW_VALUE} =           FakerLibrary.Pystr
    ...                      min_chars=${QUANT}   max_chars=${QUANT}
    Set Test Variable        ${NEW_VALUE}

Define New Number Value Less Than ${QUANT}
    ${QUANT} =               Evaluate             int($QUANT)-1
    ${NEW_VALUE} =           FakerLibrary.Pyint
    ...                      min_value=${QUANT}   max_value=${QUANT}
    Set Test Variable        ${NEW_VALUE}

Define New Number Value Greater Than ${QUANT}
    ${QUANT} =               Evaluate             int($QUANT)+1
    ${NEW_VALUE} =           FakerLibrary.Pyint
    ...                      min_value=${QUANT}   max_value=${QUANT}
    Set Test Variable        ${NEW_VALUE}

Remove Zero Values From Keys Info List
    ${quant_of_removed} =            Set Variable       ${0}
    FOR    ${index}    ${item}    IN ENUMERATE    @{KEYS_WITH_PARAMETER}
        IF  ("minLength" in $item and $item["minLength"]==0) or ("minimum" in $item and $item["minimum"]==0)
            ${index} =               Evaluate                   $index-$quant_of_removed
            Remove From List         ${KEYS_WITH_PARAMETER}     ${index}
            ${quant_of_removed} =    Evaluate                   $quant_of_removed+1
        END
    END
    Skip If                       len($KEYS_WITH_PARAMETER)==0
    ...                           msg=Endpoint does not contain key with minimum value different from zero