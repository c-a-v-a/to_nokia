*** Settings ***
Documentation     Suite for UE Detach functionality.
Library           RequestsLibrary
Library           Collections
Suite Setup       Create Session    epc_api    ${BASE_URL}
Test Setup        Reset EPC Simulator

*** Variables ***
${BASE_URL}           http://localhost:8000
${VALID_UE_ID}        ${5}         
${INVALID_UE_ID}      ${999}       

*** Test Cases ***
TC-005: Succeed with valid UE ID
    [Documentation]    Verify successful detachment of a connected UE.
    Attach UE To Network    ${VALID_UE_ID}
    Detach UE From Network    ${VALID_UE_ID}
    Verify If UE Is Detached    ${VALID_UE_ID}

TC-006: Fail when UE ID is invalid
    [Documentation]    Verify that ID out of range returns 400.
    Check If Detaching UE Fails With 400    ${INVALID_UE_ID}

TC-007: Fail when UE is not connected
    [Documentation]    Verify that detaching a non-connected UE returns 400.
    Check If Detaching UE Fails With 400    ${VALID_UE_ID}

TC-008: Fail when UE ID is not provided
    [Documentation]    Verify that missing ID in path returns 405 Method Not Allowed.
    Check If Detaching Without ID Fails

*** Keywords ***
Reset EPC Simulator
    POST On Session    epc_api    /reset

Attach UE To Network
    [Arguments]    ${ue_id}
    ${body}=    Create Dictionary    ue_id=${ue_id}
    POST On Session    epc_api    /ues    json=${body}

Detach UE From Network
    [Arguments]    ${ue_id}
    ${resp}=    DELETE On Session    epc_api    /ues/${ue_id}
    Should Be Equal As Integers    ${resp.status_code}    200

Check If Detaching UE Fails With 400
    [Arguments]    ${ue_id}    
    DELETE On Session    epc_api    /ues/${ue_id}    expected_status=400

Check If Detaching Without ID Fails    
    DELETE On Session    epc_api    /ues/    expected_status=405

Verify If UE Is Detached
    [Arguments]    ${ue_id}
    ${resp}=    GET On Session    epc_api    /ues
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    List Should Not Contain Value    ${resp.json()['ues']}    ${ue_id_int}