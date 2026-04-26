*** Settings ***
Documentation     Functionality 9: Reset Simulator
Library           RequestsLibrary
Library           Collections
Suite Setup       Create API Session
Test Setup        Reset API State

*** Variables ***
${BASE_URL}       http://127.0.0.1:8000
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
# ============================================
# Setup & Session Management
# ============================================
Create API Session
    [Documentation]    Create HTTP session for API calls
    Create Session    ue_api    ${BASE_URL}

Prepare Json Headers
    [Documentation]    Prepare Json request headers
    &{headers}=       Create Dictionary    Content-Type=application/json
    RETURN            ${headers}

Reset API State
    [Documentation]    Reset backend state before each test
    ${response}=      POST On Session    ue_api    /reset    expected_status=any
    Status Should Be    200    ${response}

# ============================================
# Keywords for Reset functionality
# ============================================
Reset simulator state
    [Documentation]    Sends a request to reset the entire simulator to its initial state.
    ${headers}=    Prepare Json Headers
    ${response}=   POST On Session    ue_api    /reset    headers=${headers}    expected_status=any
    Status Should Be    200    ${response}
    ${json}=       Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json}    status
    Should Be Equal As Strings    ${json["status"]}    reset

# ============================================
# Keywords for UE (User Equipment) management
# ============================================
Attach UE with ID ${ue_id}
    [Documentation]    Attach a new UE to the simulator
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    ue_id=${ue_id}
    ${response}=   POST On Session    ue_api    /ues    json=${body}    headers=${headers}
    Status Should Be    200    ${response}

User verifies that UE ${ue_id} is attached
    [Documentation]    Checks if a specific UE exists in the simulator.
    ${response}=   GET On Session    ue_api    /ues/${ue_id}
    Status Should Be    200    ${response}
    Should Be Equal As Integers    ${response.json()["ue_id"]}    ${ue_id}

Get UE with ID ${ue_id} should return not found
    [Documentation]    Verifies that a GET request for a UE fails (API returns 400 after reset).
    ${response}=   GET On Session    ue_api    /ues/${ue_id}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400

# ============================================
# Keywords for Bearer management
# ============================================
Add bearer to UE ${ue_id} with ID ${bearer_id}
    [Documentation]    Add a bearer to a specific UE
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    bearer_id=${bearer_id}
    ${response}=   POST On Session    ue_api    /ues/${ue_id}/bearers    json=${body}    headers=${headers}
    Status Should Be    200    ${response}

User verifies that bearer ${bearer_id} is present for UE ${ue_id}
    [Documentation]    Verify that a bearer exists for a specific UE
    ${response}=   GET On Session    ue_api    /ues/${ue_id}
    Status Should Be    200    ${response}
    ${bearers}=    Get From Dictionary    ${response.json()}    bearers
    Dictionary Should Contain Key    ${bearers}    ${bearer_id}

Get bearers for UE ${ue_id} should be empty
    [Documentation]    Checks that after reset, UE returns 400 (no longer exists).
    ${response}=   GET On Session    ue_api    /ues/${ue_id}    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    400

# ============================================
# Keywords for Traffic management
# ============================================
Set traffic for UE ${ue_id} bearer ${bearer_id} with valid data
    [Documentation]    Set traffic flow for a specific bearer
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    protocol=tcp    Mbps=10
    ${response}=   POST On Session    ue_api    /ues/${ue_id}/bearers/${bearer_id}/traffic    json=${body}    headers=${headers}
    Status Should Be    200    ${response}

Get traffic for UE ${ue_id} bearer ${bearer_id} should fail
    [Documentation]    Verifies that traffic endpoint returns error after reset.
    ${response}=   GET On Session    ue_api    /ues/${ue_id}/bearers/${bearer_id}/traffic    expected_status=any
    Should Be True    ${response.status_code} >= 400
