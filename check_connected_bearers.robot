*** Settings ***
Documentation     Functionality 7: Check Connected Bearers
Resource          shared_keywords.robot
Suite Setup       Create API Session
Test Setup        Reset API State

*** Variables ***
${VALID_UE_ID}       1
${INVALID_UE_ID}     999

*** Test Cases ***
TC-7-001 Fail when UE ID is invalid
    Checking connected bearers for UE ${INVALID_UE_ID} should fail

TC-7-002 Return correct list of connected bearers
    Attach UE with ID ${VALID_UE_ID}
    Add bearer to UE ${VALID_UE_ID} with ID 1
    Add bearer to UE ${VALID_UE_ID} with ID 2
    Verify that UE ${VALID_UE_ID} has bearers 1, 2 and 9

TC-7-003 Fail when UE ID is not provided
    [Documentation]    Attempting to check bearers without providing a UE ID in the path
    Checking connected bearers for UE ${EMPTY} should fail

*** Keywords ***
Attach UE with ID ${ue_id}
    [Documentation]    Attaches a UE to the network.
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    ue_id=${ue_id}
    Log    REQUEST: METHOD=POST URL=/ues BODY=${body}
    ${response}=   POST On Session    ue_api    /ues    json=${body}    headers=${headers}
    Status Should Be    200    ${response}

Add bearer to UE ${ue_id} with ID ${bearer_id}
    [Documentation]    Adds a bearer to the specified UE.
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    bearer_id=${bearer_id}
    Log    REQUEST: METHOD=POST URL=/ues/${ue_id}/bearers BODY=${body}
    ${response}=   POST On Session    ue_api    /ues/${ue_id}/bearers    json=${body}    headers=${headers}
    Status Should Be    200    ${response}

Checking connected bearers for UE ${ue_id} should fail
    [Documentation]    Tries to retrieve bearers for a UE and expects an error.
    Log    REQUEST: METHOD=GET URL=/ues/${ue_id}
    ${response}=   GET On Session    ue_api    /ues/${ue_id}    expected_status=any
    Should Be True    ${response.status_code} >= 400

Verify that UE ${ue_id} has bearers ${b1}, ${b2} and ${b3}
    [Documentation]    Retrieves UE details and verifies that the bearer list contains the expected IDs.
    Log    REQUEST: METHOD=GET URL=/ues/${ue_id}
    ${response}=   GET On Session    ue_api    /ues/${ue_id}
    Status Should Be    200    ${response}
    
    ${json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json}    ue_id
    Dictionary Should Contain Key    ${json}    bearers
    
    ${bearers}=    Get From Dictionary    ${json}    bearers
    # Bearer IDs are returned as strings in the JSON dictionary keys
    Dictionary Should Contain Key    ${bearers}    ${b1}
    Dictionary Should Contain Key    ${bearers}    ${b2}
    Dictionary Should Contain Key    ${bearers}    ${b3}
    
    ${count}=    Get Length    ${bearers}
    Should Be Equal As Integers    ${count}    3
