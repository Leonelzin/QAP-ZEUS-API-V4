*** Settings ***
Documentation    Resources to keywords that interact directly with the API under test.
Resource         common_resource.resource

*** Keywords ***
Get API Reference Documentation
    # The 'Find...' keywords are from 'find_documentation_info.py' ------
    [Arguments]                      ${URI}  ${METHOD}
    ${EXPECTED_STATUS_CODE} =        Find Desirable Status Code           ${URI}   ${METHOD}
    ${EXPECTED_HEADERS} =            Find Desirable Response Headers      ${URI}   ${METHOD}
    ${REQUIRED_HEADERS} =            Find Desirable Request Headers       ${URI}   ${METHOD}
    IF  "${METHOD}" == "DELETE"
        # DELETE does not have body example and schema, we need get these from other method
        ${available_methods} =       Find Methods Available To Endpoint ${URI}
        IF  "POST" in $available_methods
            ${BODY_EXAMPLE} =        Find Example Of Body                 ${URI}   POST
            ${JSON_SCHEMA} =         Find Json Schema                     ${URI}   POST
        ELSE IF  "PUT" in $available_methods
            ${BODY_EXAMPLE} =        Find Example Of Body                 ${URI}   PUT
            ${JSON_SCHEMA} =         Find Json Schema                     ${URI}   PUT
        END
    ELSE
        ${BODY_EXAMPLE} =            Find Example Of Body                 ${URI}   ${METHOD}
        ${JSON_SCHEMA} =             Find Json Schema                     ${URI}   ${METHOD}
        ${JSON_SCHEMA} =             Mix Array Schema With Item Schema    ${JSON_SCHEMA}
    END
    ${ITEMS_LIST} =                  Organize Schema As List Of Items     ${JSON_SCHEMA}
    Set Suite Variable               ${EXPECTED_STATUS_CODE}
    Set Suite Variable               ${EXPECTED_HEADERS}
    Set Suite Variable               ${REQUIRED_HEADERS}
    Set Suite Variable               ${JSON_SCHEMA}
    Set Suite Variable               ${BODY_EXAMPLE}
    Set Suite Variable               ${ITEMS_LIST}

Mix Array Schema With Item Schema
    [Arguments]                             ${SCHEMA}
    IF  $SCHEMA["type"] == "array" and "items" not in $SCHEMA
        ${ITEMS_URI} =                      Get URI With ID From ${URI}
        ${has_schema_alternative} =         Run Keyword And Return Status
        ...                                 Find Json Schema             ${ITEMS_URI}
                                            ...                          GET
        IF  ${has_schema_alternative}
            ${ITEMS_JSON_SCHEMA} =          Find Json Schema             ${ITEMS_URI}
                                            ...                          GET
            Remove From Dictionary          ${ITEMS_JSON_SCHEMA}         $schema
            Set To Dictionary               ${SCHEMA}                    items
            ...                             ${ITEMS_JSON_SCHEMA}
            Set Suite Variable              ${SCHEMA}
        END
    END
    [Return]                            ${SCHEMA}

Endpoint Contains Required Keys
    Identify Required Keys
    Skip If                        len($REQUIRED_LIST) == 0
    ...                            msg=Endpoint does not contain required keys, all are optional

Identify Required Keys
    ${REQUIRED_LIST} =            Create List
    ${OPTIONAL_LIST} =            Create List
    FOR  ${ITEM}  IN  @{ITEMS_LIST}
        IF  ${ITEM}[is_required]
            Append To List        ${REQUIRED_LIST}         ${ITEM}
        ELSE
            Append To List        ${OPTIONAL_LIST}         ${ITEM}
        END
    END
    Set Test Variable             ${REQUIRED_LIST}
    Set Test Variable             ${OPTIONAL_LIST}

Identify All Keys With Parameter "${PARAMETER}"
    ${KEYS_WITH_PARAMETER} =      Create List
    FOR  ${ITEM}  IN  @{ITEMS_LIST}
        IF  $PARAMETER in $ITEM
            Append To List        ${KEYS_WITH_PARAMETER}           ${ITEM}
        END
    END
    Set Test Variable             ${KEYS_WITH_PARAMETER}
    Skip If                       len($KEYS_WITH_PARAMETER)==0
    ...                           msg=Endpoint does not contain key with parameter ${PARAMETER}

Identify All Boolean Items
    ${BOOLEAN_LIST} =          Create List
    FOR   ${ITEM}   IN   @{ITEMS_LIST}
        IF   "type" in $ITEM and $ITEM["type"] == "boolean" and $ITEM["key"] != "default"
            Append To List     ${BOOLEAN_LIST}     ${ITEM}
        END
    END
    Set Test Variable          ${BOOLEAN_LIST}
    Skip If                    len($BOOLEAN_LIST)==0
    ...                        msg=Endpoint does not contain boolean values

Identify All Enum Items
    ${ENUM_LIST} =                 Create List
    FOR   ${ITEM}   IN   @{ITEMS_LIST}
        IF   "type" in $ITEM and $ITEM["type"] == "enum"
            Append To List         ${ENUM_LIST}         ${ITEM}
        END
    END
    Set Test Variable              ${ENUM_LIST}
    Skip If                        len($ENUM_LIST)==0
    ...                            msg=Endpoint does not contain enum values

Identify If Response Has JSON Schema
    ${HAS_JSON_SCHEMA_RESPONSE} =    Run Keyword And Return Status   Find Response Json Schema Info
    Set Suite Variable               ${HAS_JSON_SCHEMA_RESPONSE}

Find Response Json Schema Info
    ${JSON_SCHEMA_RESPONSE} =        Find Response Json Schema       ${URI}   ${METHOD}
    Set Suite Variable               ${JSON_SCHEMA_RESPONSE}

Check API Has Multiple Responses
    ${has_multiple_response_list} =     Find Post With More Than One Response
    IF  $URI in $has_multiple_response_list
        ${HAS_MULTIPLE_RESPONSE} =      Set Variable     ${True}
    ELSE
        ${HAS_MULTIPLE_RESPONSE} =      Set Variable     ${False}
    END
    Set Suite Variable                  ${HAS_MULTIPLE_RESPONSE}

Identify If Endpoint Supports Multiple Resources
    Skip If         ${JSON_SCHEMA}[type] != array
    ...             msg=Endpoint does not support multiple resources

Identify If Endpoint Is From Specific Resource
    Skip If         ${JSON_SCHEMA}[type] == array
    ...             msg=Endpoint does not support multiple resources