*** Settings ***
Resource            ../../../../resources/common_resource.resource
Force Tags          robot:continue-on-failure
Suite Setup         Run Keywords         Get API Reference Documentation   ${URI}  ${METHOD}
...                 AND                  Check API has multiple responses
...                 AND                  Identify If Response Has JSON Schema
...                 AND                  Define ID Attributtes


*** Variables ***
${URI}       /services/firewall/advanced_ip_rules
${METHOD}    POST

${LIMIT_OF_RESOURCES}   5


*** Test Case ***
POST is Succeed
    Given Connection With Web Service Is Succeed
    When Send POST Request And Save Response
    Then Status Code Should Be As Expected
    And Headers Should Be As Expected
    And Body Data Structure Should Be As JSON Schema Rule
    And All Values Must Have Been Applied

    Try To DELETE Created Resource

POST Without Authentication
    When Send POST Request Without Authentication
    Then Status Code Should Be "401"

POST With Empty Authentication
    When Send POST Request With Empty Authentication
    Then Status Code Should Be "401"

POST With Wrong Authentication
    When Send POST Request With Wrong Authentication
    Then Status Code Should Be "401"

POST Without Required Keys
    Given Connection With Web Service Is Succeed
    And Endpoint Contains Required Keys
    FOR  ${required_key}  IN  @{REQUIRED_LIST}
        When Send POST Request Without Key ${required_key}
        Then Status Code Should Be "400"
        And Response Should Contain Error Message "Field is required."
        And Response Should Inform Error Is In The Field "${required_key}"
        And Response Should Inform That Error Code Is "0"

        Try To DELETE Created Resource
    END

POST Without Optional Keys
   Given Connection With Web Service Is Succeed
   And Identify Required Keys
   FOR  ${optional_key}  IN  @{OPTIONAL_LIST}
       When Send POST Request Without Key ${optional_key}
       Then Status Code Should Be As Expected

       Try To DELETE Created Resource
   END

POST With Wrong Type Values
    Given Connection With Web Service Is Succeed
    FOR   ${item}   IN   @{ITEMS_LIST}
        And Remove Corret Type ${ITEM}[type] From Wrong Type List
        FOR   ${invalid_type}  IN  @{WRONG_TYPES}
            When Send POST Request With Invalid Type ${invalid_type} On Key ${item}
            Then Status Code Should Be "400"
            And Response Should Contain Error Message "value must be a valid ${item}[type]."
            And Response Should Inform Error Is In The Field "${item}"
            And Response Should Inform That Error Code Is "1"

            Try To DELETE Created Resource
        END
    END

POST With True Value in Boolean Fields
    Given Connection With Web Service Is Succeed
    And Identify All Boolean Items
    FOR   ${item}   IN   @{BOOLEAN_LIST}
        When Send POST Request With Value ${TRUE} On Key ${item}
        Then Status Code Should Be As Expected
        And Value ${TRUE} Must Have Been Applied To The Key ${item}

        Try To DELETE Created Resource
    END

POST With False Value in Boolean Fields
    Given Connection With Web Service Is Succeed
    And Identify All Boolean Items
    FOR   ${item}   IN   @{BOOLEAN_LIST}
        When Send POST Request With Value ${FALSE} On Key ${item}
        Then Status Code Should Be As Expected
        And Value ${FALSE} Must Have Been Applied To The Key ${item}

        Try To DELETE Created Resource
    END

POST With Valid Enum Values
    Given Connection With Web Service Is Succeed
    And Identify All Enum Items
    FOR   ${ITEM}   IN   @{ENUM_LIST}
        FOR   ${ENUM_OPTION}  IN  @{ITEM}[enum]
            When Send POST Request With Value ${ENUM_OPTION} On Key ${ITEM}
            Then Status Code Should Be As Expected
            And Value ${ENUM_OPTION} Must Have Been Applied To The Key ${ITEM}

            Try To DELETE Created Resource
        END
    END

POST With Valid Minimum Quantity of Characters
    Given Connection With Web Service Is Succeed
    And Identify All Keys With Parameter "minLength"
    FOR  ${item}  IN  @{KEYS_WITH_PARAMETER}
        And Define New Value With Quantity Of Characters Equal ${item}[minLength]
        When Send POST Request With Value ${NEW_VALUE} On Key ${item}
        Then Status Code Should Be As Expected
        And Value ${NEW_VALUE} Must Have Been Applied To The Key ${item}

        Try To DELETE Created Resource
    END

POST With Valid Maximum Quantity of Characters
    Given Connection With Web Service Is Succeed
    And Identify All Keys With Parameter "maxLength"
    FOR  ${item}  IN  @{KEYS_WITH_PARAMETER}
        And Define New Value With Quantity Of Characters Equal ${item}[maxLength]
        When Send POST Request With Value ${NEW_VALUE} On Key ${item}
        Then Status Code Should Be As Expected
        And Value ${NEW_VALUE} Must Have Been Applied To The Key ${item}

        Try To DELETE Created Resource
    END

POST With Invalid Less Than Minimum Quantity of Characters
    Given Connection With Web Service Is Succeed
    And Identify All Keys With Parameter "minLength"
    And Remove Zero Values From Keys Info List
    FOR  ${item}  IN  @{KEYS_WITH_PARAMETER}
        And Define New Value With Quantity Of Characters Less Than ${item}[minLength]
        When Send POST Request With Value ${NEW_VALUE} On Key ${item}
        Then Status Code Should Be "400"
        And Response Should Inform Error Is In The Field "${item}"
        And Response Should Inform That Error Code Is "1"
    END

POST With Invalid Greater Than Maximum Quantity of Characters
    Given Connection With Web Service Is Succeed
    And Identify All Keys With Parameter "maxLength"
    FOR  ${item}  IN  @{KEYS_WITH_PARAMETER}
        And Define New Value With Quantity Of Characters Greater Than ${item}[maxLength]
        When Send POST Request With Value ${NEW_VALUE} On Key ${item}
        Then Status Code Should Be "400"
        And Response Should Inform Error Is In The Field "${item}"
        And Response Should Inform That Error Code Is "1"
    END

POST With Valid Minimum Integer Values
    Given Connection With Web Service Is Succeed
    And Identify All Keys With Parameter "minimum"
    FOR  ${item}  IN  @{KEYS_WITH_PARAMETER}
        When Send POST Request With Value ${item}[minimum] On Key ${item}
        Then Status Code Should Be As Expected
        And Value ${item}[minimum] Must Have Been Applied To The Key ${item}

        Try To DELETE Created Resource
    END

POST With Valid Maximum Integer Values
    Given Connection With Web Service Is Succeed
    And Identify All Keys With Parameter "maximum"
    FOR  ${item}  IN  @{KEYS_WITH_PARAMETER}
        When Send POST Request With Value ${item}[maximum] On Key ${item}
        Then Status Code Should Be As Expected
        And Value ${item}[maximum] Must Have Been Applied To The Key ${item}

        Try To DELETE Created Resource
    END

POST With Invalid Less Than Minimum Integer Values
    Given Connection With Web Service Is Succeed
    And Identify All Keys With Parameter "minimum"
    FOR  ${item}  IN  @{KEYS_WITH_PARAMETER}
        And Define New Number Value Less Than ${item}[minimum]
        When Send POST Request With Value ${NEW_VALUE} On Key ${item}
        Then Status Code Should Be "400"
        And Response Should Inform Error Is In The Field "${item}"
        And Response Should Inform That Error Code Is "1"
    END

POST With Invalid Greater Than Maximum Integer Values
    Given Connection With Web Service Is Succeed
    And Identify All Keys With Parameter "maximum"
    FOR  ${item}  IN  @{KEYS_WITH_PARAMETER}
        And Define New Number Value Greater Than ${item}[maximum]
        When Send POST Request With Value ${NEW_VALUE} On Key ${item}
        Then Status Code Should Be "400"
        And Response Should Inform Error Is In The Field "${item}"
        And Response Should Inform That Error Code Is "1"
    END

POST Create New Resources Until Limit Value
    Given Connection With Web Service Is Succeed
    And Identify If Endpoint Supports Multiple Resources
    And Identify Current Quantity Of Resources
    FOR  ${resource_quantity}  IN RANGE  ${CURRENT_QUANTITY}  ${LIMIT_OF_RESOURCES}
        When Send POST Request And Save Response
        Then Status Code Should Be As Expected
        And Headers Should Be As Expected
        And Body Data Structure Should Be As JSON Schema Rule
        And All Values Must Have Been Applied
    END
    When Send GET Request And Save Response
    Then All Recourses Created Are Visible In Response

    Send DELETE Request And Save Response

POST Create New Resources Exceeding Limit Value
    Given Connection With Web Service Is Succeed
    And Identify If Endpoint Supports Multiple Resources
    And Identify Current Quantity Of Resources
    FOR  ${resource_quantity}  IN RANGE  ${CURRENT_QUANTITY}  ${LIMIT_OF_RESOURCES}+1
        When Send POST Request And Save Response
    END
    Then Status Code Should Be "400"

    Send DELETE Request And Save Response

POST With Invalid Json Data
    Given Connection With Web Service Is Succeed
    And Set A List With Invalid Json Data
    FOR  ${invalid_json}  IN  @{INVALID_JSON_LIST}
        When Send POST Request With Body ${invalid_json}
        Then Status Code Should Be "400"
        And Response Should Contain Error Message "invalid json data."
        And Response Should Inform Error Is In The Field "${EMPTY}"
        And Response Should Inform That Error Code Is "2"
    END


*** Keywords ***
