*** Settings ***
Resource            ../../../../resources/common_resource.resource
Force Tags          robot:continue-on-failure
Suite Setup         Run Keywords         Get API Reference Documentation   ${URI}  ${METHOD}
...                 AND                  Define ID Attributtes
Test Setup          Original Configuration Is Known
Test Teardown       Back To Original Configuration

*** Variables ***
${URI}       /services/radius_servers/{id}
${METHOD}    PUT


*** Test Case ***
Check endpoint availability
    Given Connection With Web Service Is Succeed
    When Send PUT Request And Save Response
    Then Status Code Should Be As Expected
    And Headers Should Be As Expected
    And Body Response Should Be Empty

PUT Without Authentication
    When Send PUT Request Without Authentication
    Then Status Code Should Be "401"

PUT With Empty Authentication
    When Send PUT Request With Empty Authentication
    Then Status Code Should Be "401"

PUT With Wrong Authentication
    When Send PUT Request With Wrong Authentication
    Then Status Code Should Be "401"

PUT Without Required Keys
    Given Connection With Web Service Is Succeed
    And Endpoint Contains Required Keys
    FOR  ${REQUIRED_KEY}  IN  @{REQUIRED_LIST}
        When Send PUT Request Without Key ${REQUIRED_KEY}
        Then Status Code Should Be "400"
        And Response Should Contain Error Message "Field is required."
        And Response Should Inform Error Is In The Field "${REQUIRED_KEY}"
        And Response Should Inform That Error Code Is "0"
    END

PUT Without Optional Keys
   Given Connection With Web Service Is Succeed
   And Identify Required Keys
   FOR  ${OPTIONAL_KEY}  IN  @{OPTIONAL_LIST}
       When Send PUT Request Without Key ${OPTIONAL_KEY}
       Then Status Code Should Be As Expected
   END

PUT With Wrong Type Values
    Given Connection With Web Service Is Succeed
    FOR   ${ITEM}   IN   @{ITEMS_LIST}
        And Remove Corret Type ${ITEM}[type] From Wrong Type List
        FOR   ${INVALID_TYPE}  IN  @{WRONG_TYPES}
            When Send PUT Request With Invalid Type ${INVALID_TYPE} On Key ${ITEM}
            Then Status Code Should Be "400"
            And Response Should Inform Error Is In The Field "${ITEM}"
            And Response Should Inform That Error Code Is "1"
        END
    END

PUT With Valid Boolean Values
    Given Connection With Web Service Is Succeed
    And Identify All Boolean Items
    FOR   ${ITEM}   IN   @{BOOLEAN_LIST}
        And Identify Current And Opposite Boolean Values Of Key ${ITEM}

        When Send PUT Request With Value ${NEW_VALUE} On Key ${ITEM}
        Then Status Code Should Be As Expected
        And Value ${NEW_VALUE} Must Have Been Applied To The Key ${ITEM}

        When Send PUT Request With Value ${ORIGINAL_VALUE} On Key ${ITEM}
        Then Status Code Should Be As Expected
        And Value ${ORIGINAL_VALUE} Must Have Been Applied To The Key ${ITEM}
    END

PUT With Valid Enum Values
    Given Connection With Web Service Is Succeed
    And Identify All Enum Items
    FOR   ${ITEM}   IN   @{ENUM_LIST}
        FOR   ${ENUM_OPTION}  IN  @{ITEM}[enum]
            When Send PUT Request With Value ${ENUM_OPTION} On Key ${ITEM}
            Then Status Code Should Be As Expected
            And Value ${ENUM_OPTION} Must Have Been Applied To The Key ${ITEM}
        END
    END

PUT With Valid Minimum Quantity of Characters
    Given Connection With Web Service Is Succeed
    And Identify All Keys With Parameter "minLength"
    FOR  ${item}  IN  @{KEYS_WITH_PARAMETER}
        And Define New Value With Quantity Of Characters Equal ${item}[minLength]
        When Send PUT Request With Value ${NEW_VALUE} On Key ${item}
        Then Status Code Should Be As Expected
        And Value ${NEW_VALUE} Must Have Been Applied To The Key ${item}
    END

PUT With Valid Maximum Quantity of Characters
    Given Connection With Web Service Is Succeed
    And Identify All Keys With Parameter "maxLength"
    FOR  ${item}  IN  @{KEYS_WITH_PARAMETER}
        And Define New Value With Quantity Of Characters Equal ${item}[maxLength]
        When Send PUT Request With Value ${NEW_VALUE} On Key ${item}
        Then Status Code Should Be As Expected
        And Value ${NEW_VALUE} Must Have Been Applied To The Key ${item}
    END

PUT With Invalid Less Than Minimum Quantity of Characters
    Given Connection With Web Service Is Succeed
    And Identify All Keys With Parameter "minLength"
    And Remove Zero Values From Keys Info List
    FOR  ${item}  IN  @{KEYS_WITH_PARAMETER}
        And Define New Value With Quantity Of Characters Less Than ${item}[minLength]
        When Send PUT Request With Value ${NEW_VALUE} On Key ${item}
        Then Status Code Should Be "400"
        And Response Should Inform Error Is In The Field "${item}"
        And Response Should Inform That Error Code Is "1"
    END

PUT With Invalid Greater Than Maximum Quantity of Characters
    Given Connection With Web Service Is Succeed
    And Identify All Keys With Parameter "maxLength"
    FOR  ${item}  IN  @{KEYS_WITH_PARAMETER}
        And Define New Value With Quantity Of Characters Greater Than ${item}[maxLength]
        When Send PUT Request With Value ${NEW_VALUE} On Key ${item}
        Then Status Code Should Be "400"
        And Response Should Inform Error Is In The Field "${item}"
        And Response Should Inform That Error Code Is "1"
    END

PUT With Valid Minimum Integer Values
    Given Connection With Web Service Is Succeed
    And Identify All Keys With Parameter "minimum"
    FOR  ${item}  IN  @{KEYS_WITH_PARAMETER}
        When Send PUT Request With Value ${item}[minimum] On Key ${item}
        Then Status Code Should Be As Expected
        And Value ${item}[minimum] Must Have Been Applied To The Key ${item}
    END

PUT With Valid Maximum Integer Values
    Given Connection With Web Service Is Succeed
    And Identify All Keys With Parameter "maximum"
    FOR  ${item}  IN  @{KEYS_WITH_PARAMETER}
        When Send PUT Request With Value ${item}[maximum] On Key ${item}
        Then Status Code Should Be As Expected
        And Value ${item}[maximum] Must Have Been Applied To The Key ${item}
    END

PUT With Invalid Less Than Minimum Integer Values
    Given Connection With Web Service Is Succeed
    And Identify All Keys With Parameter "minimum"
    FOR  ${item}  IN  @{KEYS_WITH_PARAMETER}
        And Define New Number Value Less Than ${item}[minimum]
        When Send PUT Request With Value ${NEW_VALUE} On Key ${item}
        Then Status Code Should Be "400"
        And Response Should Inform Error Is In The Field "${item}"
        And Response Should Inform That Error Code Is "1"
    END

PUT With Invalid Greater Than Maximum Integer Values
    Given Connection With Web Service Is Succeed
    And Identify All Keys With Parameter "maximum"
    FOR  ${item}  IN  @{KEYS_WITH_PARAMETER}
        And Define New Number Value Greater Than ${item}[maximum]
        When Send PUT Request With Value ${NEW_VALUE} On Key ${item}
        Then Status Code Should Be "400"
        And Response Should Inform Error Is In The Field "${item}"
        And Response Should Inform That Error Code Is "1"
    END

PUT With Invalid Json Data
    Given Connection With Web Service Is Succeed
    And Set A List With Invalid Json Data
    FOR  ${invalid_json}  IN  @{INVALID_JSON_LIST}
        When Send PUT Request With Body ${invalid_json}
        Then Status Code Should Be "400"
        And Response Should Contain Error Message "invalid json data."
        And Response Should Inform Error Is In The Field "${EMPTY}"
        And Response Should Inform That Error Code Is "2"
    END
