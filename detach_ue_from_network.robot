*** Settings ***
Documentation     Suite for UE Detach functionality.
Library           RequestsLibrary
Library           Collections
Suite Setup       Create Session    epc_api    ${BASE_URL}
Test Setup        Reset EPC Simulator

*** Variables ***
${BASE_URL}           http://localhost:8000
${MIN_VALID_UE_ID}    ${1}         
${MAX_VALID_UE_ID}    ${100}       
${MIN_INVALID_UE_ID}  ${0}         
${MAX_INVALID_UE_ID}  ${101}       
${STRING_UE_ID}       invalid_id

*** Test Cases ***
TC-2-001: Succeed to detach UE with minimum valid ID
    [Documentation]    Verify successful detachment for the lowest allowed UE ID (1).
    Attach UE To Network    ${MIN_VALID_UE_ID}
    Detach UE From Network    ${MIN_VALID_UE_ID}
    Verify If UE Is Not Attached    ${MIN_VALID_UE_ID}

TC-2-002: Succeed to detach UE with maximum valid ID
    [Documentation]    Verify successful detachment for the highest allowed UE ID (100).
    Attach UE To Network    ${MAX_VALID_UE_ID}
    Detach UE From Network    ${MAX_VALID_UE_ID}
    Verify If UE Is Not Attached    ${MAX_VALID_UE_ID}

TC-2-003: Fail when detaching UE with ID just below minimum
    [Documentation]    Verify validation error when UE ID is 0 during detach.
    Attempt To Detach UE With Out Of Range ID   ${MIN_INVALID_UE_ID}

TC-2-004: Fail when detaching UE with ID just above maximum
    [Documentation]    Verify validation error when UE ID is 101 during detach.
    Attempt To Detach UE With Out Of Range ID    ${MAX_INVALID_UE_ID}

TC-2-005: Fail when detaching UE with string ID
    [Documentation]    Verify validation error when UE ID is a string.
    Attempt To Detach UE With Invalid ID Type    ${STRING_UE_ID}

TC-2-006: Fail when UE ID is not provided
    [Documentation]    Verify Method Not Allowed when ID is missing from the URL path.
    Attempt To Detach Without ID

TC-2-007: Fail when UE is not connected
    [Documentation]    Verify bad request error when trying to detach a UE that is not in the network.
    Attempt To Detach Unconnected UE    ${50}

TC-2-008: Succeed to re-attach UE after successful detach
    [Documentation]    Verify state transition: Attach -> Detach -> Attach successfully.
    Attach UE To Network    ${10}
    Detach UE From Network    ${10}
    Attach UE To Network    ${10}
    Verify If UE Is Attached    ${10}

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


Attempt To Detach UE With Out Of Range ID
    [Arguments]    ${ue_id}    
    DELETE On Session    epc_api    /ues/${ue_id}    expected_status=400

Attempt To Detach UE With Invalid ID Type
    [Arguments]    ${ue_id}    
    DELETE On Session    epc_api    /ues/${ue_id}    expected_status=422    

Attempt To Detach Unconnected UE
    [Arguments]    ${ue_id}   
    DELETE On Session    epc_api    /ues/${ue_id}    expected_status=400

Attempt To Detach Without ID
    DELETE On Session    epc_api    /ues/    expected_status=405

Verify If UE Is Attached
    [Arguments]    ${ue_id}
    ${resp}=    GET On Session    epc_api    /ues
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    List Should Contain Value    ${resp.json()['ues']}    ${ue_id_int}

Verify If UE Is Not Attached
    [Arguments]    ${ue_id}
    ${resp}=    GET On Session    epc_api    /ues
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    List Should Not Contain Value    ${resp.json()['ues']}    ${ue_id_int}