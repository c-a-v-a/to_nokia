*** Settings ***
Documentation     Functionality 9: Reset Simulator
Resource          ./shared_keywords.robot
Suite Setup       Create API Session
Test Setup        Reset API State

*** Variables ***
${VALID_UE_ID_1}     1
${VALID_UE_ID_2}     100
${VALID_BEARER_ID}   5

*** Test Cases ***
TC-044: Reset affects attached UEs
    [Documentation]    Verify that after reset, previously attached UEs are no longer present.
    Attach UE with ID ${VALID_UE_ID_1}
    Attach UE with ID ${VALID_UE_ID_2}
    User verifies that UE ${VALID_UE_ID_1} is attached
    User verifies that UE ${VALID_UE_ID_2} is attached

    Reset simulator state

    Get UE with ID ${VALID_UE_ID_1} should return not found
    Get UE with ID ${VALID_UE_ID_2} should return not found

TC-045: Reset affects ongoing data transfers
    [Documentation]    Verify that after reset, any active traffic flow is terminated.
    Attach UE with ID ${VALID_UE_ID_1}
    Add bearer to UE ${VALID_UE_ID_1} with ID ${VALID_BEARER_ID}
    Set traffic for UE ${VALID_UE_ID_1} bearer ${VALID_BEARER_ID} with valid data

    Reset simulator state

    Get traffic for UE ${VALID_UE_ID_1} bearer ${VALID_BEARER_ID} should fail

TC-046: Reset affects transport channels
    [Documentation]    Verify that after reset, all bearers are removed for previously attached UEs.
    Attach UE with ID ${VALID_UE_ID_1}
    Add bearer to UE ${VALID_UE_ID_1} with ID ${VALID_BEARER_ID}
    User verifies that bearer ${VALID_BEARER_ID} is present for UE ${VALID_UE_ID_1}

    Reset simulator state

    Get bearers for UE ${VALID_UE_ID_1} should be empty

*** Keywords ***
Reset simulator state
    [Documentation]    Sends a request to reset the entire simulator to its initial state.
    ${headers}=    Prepare Json Headers
    ${response}=   POST On Session    ue_api    /reset    headers=${headers}    expected_status=any
    Status Should Be    200    ${response}
    ${json}=       Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json}    status
    Should Be Equal As Strings    ${json["status"]}    success

User verifies that UE ${ue_id} is attached
    [Documentation]    Checks if a specific UE exists in the simulator.
    ${response}=   GET On Session    ue_api    /ues/${ue_id}
    Status Should Be    200    ${response}
    Should Be Equal As Integers    ${response.json()["ue_id"]}    ${ue_id}

Get UE with ID ${ue_id} should return not found
    [Documentation]    Verifies that a GET request for a UE fails (e.g., 404 Not Found).
    ${response}=   GET On Session    ue_api    /ues/${ue_id}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    404

Get bearers for UE ${ue_id} should be empty
    [Documentation]    Checks that the list of bearers for a given UE is empty.
    ${response}=   GET On Session    ue_api    /ues/${ue_id}
    Status Should Be    200    ${response}
    ${bearers}=    Get From Dictionary    ${response.json()}    bearers
    Dictionary Should Be Empty    ${bearers}