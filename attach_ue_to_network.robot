*** Settings ***
Documentation     Suite for UE Attach functionality.
Library           RequestsLibrary
Library           Collections
Suite Setup       Create Session    epc_api    ${BASE_URL}
Test Setup        Reset EPC Simulator

*** Variables ***
${BASE_URL}           http://localhost:8000
${MIN_VALID_UE_ID}    ${0}         
${MAX_VALID_UE_ID}    ${100}       
${MIN_INVALID_UE_ID}  ${-1}         
${MAX_INVALID_UE_ID}  ${101}       
${STRING_UE_ID}       invalid_id
${FLOAT_UE_ID}        ${1.5}
${DEFAULT_BEARER}     ${9}    
${EXAMPLE_UE_ID}      ${50}      

*** Test Cases ***
TC-1-001: Succeed when attaching UE with minimum valid ID
    [Documentation]    Verify successful attachment for the lowest allowed UE ID (0).
    Attach UE To Network    ${MIN_VALID_UE_ID}
    Verify If UE Is Attached    ${MIN_VALID_UE_ID}
    Verify If UE Has Default Bearer    ${MIN_VALID_UE_ID}    ${DEFAULT_BEARER}

TC-1-002: Succeed when attaching UE with maximum valid ID
    [Documentation]    Verify successful attachment for the highest allowed UE ID (100).
    Attach UE To Network    ${MAX_VALID_UE_ID}
    Verify If UE Is Attached    ${MAX_VALID_UE_ID}
    Verify If UE Has Default Bearer    ${MAX_VALID_UE_ID}    ${DEFAULT_BEARER}

TC-1-003: Fail when attaching UE with ID just below minimum
    [Documentation]    Verify validation error when UE ID is -1.
    Attempt To Attach UE With Invalid Data    ${MIN_INVALID_UE_ID}
    Verify If UE Is Not Attached    ${MIN_INVALID_UE_ID}

TC-1-004: Fail when attaching UE with ID just above maximum
    [Documentation]    Verify validation error when UE ID is 101.
    Attempt To Attach UE With Invalid Data    ${MAX_INVALID_UE_ID}
    Verify If UE Is Not Attached    ${MAX_INVALID_UE_ID}

TC-1-005: Fail when attaching UE with string ID
    [Documentation]    Verify validation error when UE ID is a string.
    Attempt To Attach UE With Invalid Data    ${STRING_UE_ID}

TC-1-006: Fail when attaching UE with float ID
    [Documentation]    Verify validation error when UE ID is a floating point number.
    Attempt To Attach UE With Invalid Data    ${FLOAT_UE_ID}

TC-1-007: Fail when UE ID is not provided
    [Documentation]    Verify validation error when payload is missing the UE ID.
    Attempt To Attach UE Without ID

TC-1-008: Fail when UE is already connected
    [Documentation]    Verify bad request error when trying to attach an already attached UE.
    Attach UE To Network    ${EXAMPLE_UE_ID}
    Attempt To Attach Already Connected UE    ${EXAMPLE_UE_ID}

TC-1-009: Succeed to attach multiple different UEs sequentially
    [Documentation]    Verify that multiple UEs can exist in the network simultaneously.
    Attach UE To Network    ${10}
    Attach UE To Network    ${11}
    Verify If UE Is Attached    ${10}
    Verify If UE Is Attached    ${11}

*** Keywords ***
Reset EPC Simulator
    POST On Session    epc_api    /reset

Attach UE To Network
    [Arguments]    ${ue_id}
    ${body}=    Create Dictionary    ue_id=${ue_id}
    ${resp}=    POST On Session    epc_api    /ues    json=${body}
    Should Be Equal As Integers    ${resp.status_code}    200

Attempt To Attach UE With Invalid Data
    [Arguments]    ${ue_id}
    ${body}=    Create Dictionary    ue_id=${ue_id}
    
    ${resp}=    POST On Session    epc_api    /ues    json=${body}    expected_status=422

Attempt To Attach Already Connected UE
    [Arguments]    ${ue_id}
    ${body}=    Create Dictionary    ue_id=${ue_id}    
    ${resp}=    POST On Session    epc_api    /ues    json=${body}    expected_status=400

Attempt To Attach UE Without ID
    ${body}=    Create Dictionary
    ${resp}=    POST On Session    epc_api    /ues    json=${body}    expected_status=422

Verify If UE Is Attached
    [Arguments]    ${ue_id}
    ${resp}=    GET On Session    epc_api    /ues    
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    List Should Contain Value    ${resp.json()['ues']}    ${ue_id_int}

Verify If UE Is Not Attached
    [Arguments]    ${ue_id}
    ${resp}=    GET On Session    epc_api    /ues    
    ${ue_id_string_check}=    Convert To String    ${ue_id}    
    Run Keyword And Ignore Error    List Should Not Contain Value    ${resp.json()['ues']}    ${ue_id}

Verify If UE Has Default Bearer
    [Arguments]    ${ue_id}    ${bearer_id}
    ${resp}=    GET On Session    epc_api    /ues/${ue_id}    
    ${bearer_str}=    Convert To String    ${bearer_id}
    Dictionary Should Contain Key    ${resp.json()['bearers']}    ${bearer_str}
