*** Settings ***
Documentation     Functionality 6: Add Bearer
Resource          shared_keywords.robot
Suite Setup       Create API Session
Test Setup        Reset API State

*** Variables ***
${VALID_UE_ID}       1
${VALID_BEARER_ID}   2
${INVALID_UE_ID}     999
${INVALID_BEARER_ID}   10

*** Test Cases ***
TC-028: Fail when UE ID is invalid
    Adding bearer to UE ${INVALID_UE_ID} with ID ${VALID_BEARER_ID} should fail

TC-029: Fail when bearer ID is invalid
    Attach UE with ID ${VALID_UE_ID}
    Adding bearer to UE ${VALID_UE_ID} with ID ${INVALID_BEARER_ID} should fail

TC-030: Fail when bearer ID already exists
    Attach UE with ID ${VALID_UE_ID}
    Add bearer to UE ${VALID_UE_ID} with ID ${VALID_BEARER_ID}
    Adding bearer to UE ${VALID_UE_ID} with ID ${VALID_BEARER_ID} should fail

TC-031: Succeed with valid data
    Attach UE with ID ${VALID_UE_ID}
    Add bearer to UE ${VALID_UE_ID} with ID ${VALID_BEARER_ID}
    User verifies that bearer ${VALID_BEARER_ID} is present for UE ${VALID_UE_ID}

TC-032: Fail when UE ID is not provided
    [Documentation]    Attempting to add a bearer without specifying a UE ID in the path
    Adding bearer to UE ${EMPTY} with ID ${VALID_BEARER_ID} should fail

TC-033: Fail when bearer ID is not provided
    Attach UE with ID ${VALID_UE_ID}
    Attempt to add bearer to UE ${VALID_UE_ID} without providing any ID should fail

*** Keywords ***
Attach UE with ID ${ue_id}
    [Documentation]    Attaches a User Equipment (UE) to the EPC simulator.
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    ue_id=${ue_id}
    ${response}=   POST On Session    ue_api    /ues    json=${body}    headers=${headers}
    Status Should Be    200    ${response}

Add bearer to UE ${ue_id} with ID ${bearer_id}
    [Documentation]    Adds a transport channel (bearer) to a specific UE.
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    bearer_id=${bearer_id}
    ${response}=   POST On Session    ue_api    /ues/${ue_id}/bearers    json=${body}    headers=${headers}
    Status Should Be    200    ${response}

Adding bearer to UE ${ue_id} with ID ${bearer_id} should fail
    [Documentation]    Attempts to add a bearer and expects the request to be rejected.
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    bearer_id=${bearer_id}
    ${response}=   POST On Session    ue_api    /ues/${ue_id}/bearers    json=${body}    headers=${headers}    expected_status=any
    # Status can be 422 (Validation Error) or 404 (UE Not Found)
    Should Be True    ${response.status_code} >= 400

User verifies that bearer ${bearer_id} is present for UE ${ue_id}
    [Documentation]    Checks if the bearer exists in the UE's configuration.
    ${response}=   GET On Session    ue_api    /ues/${ue_id}
    Status Should Be    200    ${response}
    ${bearers}=    Get From Dictionary    ${response.json()}    bearers
    Dictionary Should Contain Key    ${bearers}    ${bearer_id}

Attempt to add bearer to UE ${ue_id} without providing any ID should fail
    [Documentation]    Sends a request to add a bearer but omits the bearer_id from the request body.
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary
    ${response}=   POST On Session    ue_api    /ues/${ue_id}/bearers    json=${body}    headers=${headers}    expected_status=any
    Status Should Be    422    ${response}
