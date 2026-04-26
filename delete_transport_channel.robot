*** Settings ***
Documentation     Functionality 8: Delete Bearer
Resource          shared_keywords.robot
Suite Setup       Create API Session
Test Setup        Reset API State

*** Variables ***
${VALID_UE_ID}       1
${INVALID_UE_ID}     999
${DEFAULT_BEARER}    9
${EXTRA_BEARER}      2

*** Test Cases ***
TC-8-001 Fail when UE ID is invalid
    Deleting bearer 1 for UE ${INVALID_UE_ID} should fail

TC-8-002 Fail when bearer ID is invalid
    Attach UE with ID ${VALID_UE_ID}
    Deleting bearer 10 for UE ${VALID_UE_ID} should fail

TC-8-003 Fail when bearer ID is inactive
    Attach UE with ID ${VALID_UE_ID}
    Deleting bearer ${EXTRA_BEARER} for UE ${VALID_UE_ID} should fail

TC-8-004 Fail when deleting default bearer
    [Documentation]    Verify that the default bearer (ID 9) cannot be removed, as per documentation.
    Attach UE with ID ${VALID_UE_ID}
    Deleting bearer ${DEFAULT_BEARER} for UE ${VALID_UE_ID} should fail

TC-8-005 Successfully delete bearer with valid data
    Attach UE with ID ${VALID_UE_ID}
    Add bearer to UE ${VALID_UE_ID} with ID ${EXTRA_BEARER}
    Delete bearer ${EXTRA_BEARER} for UE ${VALID_UE_ID}
    Verify that bearer ${EXTRA_BEARER} was removed from UE ${VALID_UE_ID}

TC-8-006 Fail when UE ID is not provided
    [Documentation]    Attempting to delete a bearer without providing a UE ID in the path
    Deleting bearer 1 for UE ${EMPTY} should fail

TC-8-007 Fail when bearer ID is not provided
    Attach UE with ID ${VALID_UE_ID}
    Attempting to delete bearer without providing ID for UE ${VALID_UE_ID} should fail

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

Delete bearer ${bearer_id} for UE ${ue_id}
    [Documentation]    Sends a DELETE request to remove a specific bearer.
    Log    REQUEST: METHOD=DELETE URL=/ues/${ue_id}/bearers/${bearer_id}
    ${response}=   DELETE On Session    ue_api    /ues/${ue_id}/bearers/${bearer_id}
    Status Should Be    200    ${response}
    
    ${json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json}    status
    Dictionary Should Contain Key    ${json}    ue_id
    Dictionary Should Contain Key    ${json}    bearer_id
    
    Should Be Equal As Integers    ${json["ue_id"]}    ${ue_id}
    Should Be Equal As Integers    ${json["bearer_id"]}    ${bearer_id}

Deleting bearer ${bearer_id} for UE ${ue_id} should fail
    [Documentation]    Tries to delete a bearer and expects an error response.
    Log    REQUEST: METHOD=DELETE URL=/ues/${ue_id}/bearers/${bearer_id}
    ${response}=   DELETE On Session    ue_api    /ues/${ue_id}/bearers/${bearer_id}    expected_status=any
    Should Be True    ${response.status_code} >= 400

Verify that bearer ${bearer_id} was removed from UE ${ue_id}
    [Documentation]    Checks the UE details to confirm the bearer is no longer present.
    Log    REQUEST: METHOD=GET URL=/ues/${ue_id}
    ${response}=   GET On Session    ue_api    /ues/${ue_id}
    Status Should Be    200    ${response}
    ${bearers}=    Get From Dictionary    ${response.json()}    bearers
    Dictionary Should Not Contain Key    ${bearers}    ${bearer_id}

Attempting to delete bearer without providing ID for UE ${ue_id} should fail
    [Documentation]    Sends a DELETE request with a missing bearer ID segment in the URL.
    Log    REQUEST: METHOD=DELETE URL=/ues/${ue_id}/bearers/
    ${response}=   DELETE On Session    ue_api    /ues/${ue_id}/bearers/    expected_status=any
    Should Be True    ${response.status_code} >= 400
