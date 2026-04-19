*** Settings ***
Documentation     Suite for UE Attach functionality.
Library           RequestsLibrary
Library           Collections
Suite Setup       Create Session    epc_api    ${BASE_URL}
Test Setup        Reset EPC Simulator

*** Variables ***
${BASE_URL}           http://localhost:8000
${VALID_UE_ID}        ${1}         
${INVALID_UE_ID}      ${101}       
${ALREADY_CONNECTED}  ${2}         
${DEFAULT_BEARER}     ${9}         

*** Test Cases ***
TC-001: Fail when UE ID is not provided
    [Documentation]    Verify validation error (422) when ID is missing.
    Check If Attaching UE Without ID Fails

TC-002: Fail when UE ID is invalid
    [Documentation]    Verify validation error (422) when ID is out of range.
    Check If Attaching UE Fails With 422    ${INVALID_UE_ID}

TC-003: Fail when UE is already connected
    [Documentation]    Verify bad request (400) when UE is already in the network.
    Attach UE To Network    ${ALREADY_CONNECTED}
    Check If Attaching UE Fails With 400    ${ALREADY_CONNECTED}

TC-004: Succeed when valid UE ID is provided and bearer ID = 9
    [Documentation]    Verify successful attachment and default bearer assignment.
    Attach UE To Network    ${VALID_UE_ID}
    Verify If UE Is Attached    ${VALID_UE_ID}
    Verify If UE Has Default Bearer    ${VALID_UE_ID}    ${DEFAULT_BEARER}

*** Keywords ***
Reset EPC Simulator
    POST On Session    epc_api    /reset

Attach UE To Network
    [Arguments]    ${ue_id}
    ${body}=    Create Dictionary    ue_id=${ue_id}
    ${resp}=    POST On Session    epc_api    /ues    json=${body}
    Should Be Equal As Integers    ${resp.status_code}    200

Check If Attaching UE Fails With 422
    [Arguments]    ${ue_id}
    ${body}=    Create Dictionary    ue_id=${ue_id}
    ${resp}=    POST On Session    epc_api    /ues    json=${body}    expected_status=422

Check If Attaching UE Fails With 400
    [Arguments]    ${ue_id}
    ${body}=    Create Dictionary    ue_id=${ue_id}
    ${resp}=    POST On Session    epc_api    /ues    json=${body}    expected_status=400

Check If Attaching UE Without ID Fails
    ${body}=    Create Dictionary
    ${resp}=    POST On Session    epc_api    /ues    json=${body}    expected_status=422

Verify If UE Is Attached
    [Arguments]    ${ue_id}
    ${resp}=    GET On Session    epc_api    /ues    
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    List Should Contain Value    ${resp.json()['ues']}    ${ue_id_int}

Verify If UE Has Default Bearer
    [Arguments]    ${ue_id}    ${bearer_id}
    ${resp}=    GET On Session    epc_api    /ues/${ue_id}    
    ${bearer_str}=    Convert To String    ${bearer_id}
    Dictionary Should Contain Key    ${resp.json()['bearers']}    ${bearer_str}