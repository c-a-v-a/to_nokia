*** Settings ***
Documentation     Functionalities 3, 4 and 5 related to data traffic.
Resource          ./shared_keywords.robot
Suite Setup       Create API Session
Test Setup        Reset API State

*** Variables ***
${VALID_UE_ID}         1
${VALID_BEARER_ID}     2
${INVALID_UE_ID}       999
${INVALID_BEARER_ID}   10
${PROTOCOL}            tcp

*** Test Cases ***
TC-009: Allow transfer only in DL
    Attach UE with ID ${VALID_UE_ID}
    Add bearer to UE ${VALID_UE_ID} with ID ${VALID_BEARER_ID}
    Set traffic for UE ${VALID_UE_ID} bearer ${VALID_BEARER_ID} with valid data
    Status Should Be    200    ${LAST_RESPONSE}

TC-010: Fail when transfer speed is invalid
    Attach UE with ID ${VALID_UE_ID}
    Add bearer to UE ${VALID_UE_ID} with ID ${VALID_BEARER_ID}
    Set traffic with invalid speed for UE ${VALID_UE_ID} bearer ${VALID_BEARER_ID} should fail

TC-011: Fail when UE ID is invalid
    Set traffic for UE ${INVALID_UE_ID} bearer ${VALID_BEARER_ID} should fail

TC-012: Fail when bearer ID is inactive
    Attach UE with ID ${VALID_UE_ID}
    Set traffic for UE ${VALID_UE_ID} bearer ${VALID_BEARER_ID} should fail

TC-013: Succeed with valid data
    Attach UE with ID ${VALID_UE_ID}
    Add bearer to UE ${VALID_UE_ID} with ID ${VALID_BEARER_ID}
    Set traffic for UE ${VALID_UE_ID} bearer ${VALID_BEARER_ID} with valid data

TC-014: Fail when UE ID is not provided
    Attempt to set traffic without UE ID should fail

TC-015: Fail when bearer ID is not provided
    Attach UE with ID ${VALID_UE_ID}
    Attempt to set traffic without bearer ID should fail

TC-016: Fail when transfer speed is not provided
    Attach UE with ID ${VALID_UE_ID}
    Add bearer to UE ${VALID_UE_ID} with ID ${VALID_BEARER_ID}
    Attempt to set traffic without speed should fail

TC-017: Retrieve status for a specific bearer
    Attach UE with ID ${VALID_UE_ID}
    Add bearer to UE ${VALID_UE_ID} with ID ${VALID_BEARER_ID}
    Set traffic for UE ${VALID_UE_ID} bearer ${VALID_BEARER_ID} with valid data
    Get traffic for UE ${VALID_UE_ID} bearer ${VALID_BEARER_ID}

TC-018: Retrieve status for all bearers
    Attach UE with ID ${VALID_UE_ID}
    Add bearer to UE ${VALID_UE_ID} with ID 1
    Add bearer to UE ${VALID_UE_ID} with ID 2
    Set traffic for UE ${VALID_UE_ID} bearer 1 with valid data
    Set traffic for UE ${VALID_UE_ID} bearer 2 with valid data
    Get all traffic for UE ${VALID_UE_ID}

TC-019: Default unit is kbps
    Attach UE with ID ${VALID_UE_ID}
    Add bearer to UE ${VALID_UE_ID} with ID ${VALID_BEARER_ID}
    Set traffic for UE ${VALID_UE_ID} bearer ${VALID_BEARER_ID} with kbps 1000
    Verify target bps for UE ${VALID_UE_ID} bearer ${VALID_BEARER_ID} is 1000000

TC-020: Fail when bearer ID is invalid
    Attach UE with ID ${VALID_UE_ID}
    Get traffic for UE ${VALID_UE_ID} bearer ${INVALID_BEARER_ID} should fail

TC-021: Fail when UE ID is invalid
    Get traffic for UE ${INVALID_UE_ID} bearer ${VALID_BEARER_ID} should fail

TC-022: Fail when UE ID is not provided
    Attempt to get traffic without UE ID should fail

*** Keywords ***
Attach UE with ID ${ue_id}
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    ue_id=${ue_id}
    ${response}=   POST On Session    ue_api    /ues    json=${body}    headers=${headers}
    Status Should Be    200    ${response}

Add bearer to UE ${ue_id} with ID ${bearer_id}
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    bearer_id=${bearer_id}
    ${response}=   POST On Session    ue_api    /ues/${ue_id}/bearers    json=${body}    headers=${headers}
    Status Should Be    200    ${response}

Set traffic for UE ${ue_id} bearer ${bearer_id} with valid data
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    protocol=${PROTOCOL}    Mbps=10
    ${response}=   POST On Session    ue_api    /ues/${ue_id}/bearers/${bearer_id}/traffic    json=${body}    headers=${headers}
    Set Suite Variable    ${LAST_RESPONSE}    ${response}
    Status Should Be    200    ${response}
    ${json}=    Set Variable    ${response.json()}

    Dictionary Should Contain Key    ${json}    status
    Dictionary Should Contain Key    ${json}    ue_id
    Dictionary Should Contain Key    ${json}    bearer_id
    Dictionary Should Contain Key    ${json}    target_bps

    Should Be Equal As Integers    ${json["ue_id"]}    ${ue_id}
    Should Be Equal As Integers   ${json["bearer_id"]}    ${bearer_id}

    ${expected_bps}=    Evaluate    10 * 1000 * 1000
    Should Be Equal    ${json["target_bps"]}    ${expected_bps}

Set traffic for UE ${ue_id} bearer ${bearer_id} should fail
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    protocol=${PROTOCOL}    Mbps=10
    ${response}=   POST On Session    ue_api    /ues/${ue_id}/bearers/${bearer_id}/traffic    json=${body}    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} >= 400

Set traffic with invalid speed for UE ${ue_id} bearer ${bearer_id} should fail
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    protocol=${PROTOCOL}    Mbps=-1
    ${response}=   POST On Session    ue_api    /ues/${ue_id}/bearers/${bearer_id}/traffic    json=${body}    headers=${headers}    expected_status=any
    Status Should Be    422    ${response}

Attempt to set traffic without UE ID should fail
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    protocol=${PROTOCOL}    Mbps=10
    ${response}=   POST On Session    ue_api    /ues//bearers/${VALID_BEARER_ID}/traffic    json=${body}    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} >= 400

Attempt to set traffic without bearer ID should fail
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    protocol=${PROTOCOL}    Mbps=10
    ${response}=   POST On Session    ue_api    /ues/${VALID_UE_ID}/bearers//traffic    json=${body}    headers=${headers}    expected_status=any
    Should Be True    ${response.status_code} >= 400

Attempt to set traffic without speed should fail
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    protocol=${PROTOCOL}
    ${response}=   POST On Session    ue_api    /ues/${VALID_UE_ID}/bearers/${VALID_BEARER_ID}/traffic    json=${body}    headers=${headers}    expected_status=any
    Status Should Be    422    ${response}

Get traffic for UE ${ue_id} bearer ${bearer_id}
    ${response}=   GET On Session    ue_api    /ues/${ue_id}/bearers/${bearer_id}/traffic
    Status Should Be    200    ${response}

    ${json}=    Set Variable    ${response.json()}

    Dictionary Should Contain Key    ${json}    ue_id
    Dictionary Should Contain Key    ${json}    bearer_id
    Dictionary Should Contain Key    ${json}    protocol
    Dictionary Should Contain Key    ${json}    target_bps
    Dictionary Should Contain Key    ${json}    tx_bps
    Dictionary Should Contain Key    ${json}    rx_bps
    Dictionary Should Contain Key    ${json}    duration

    Should Be Equal As Integers    ${json["ue_id"]}    ${ue_id}
    Should Be Equal As Integers    ${json["bearer_id"]}    ${bearer_id}

Get all traffic for UE ${ue_id}
    ${response}=   GET On Session    ue_api    /ues/${ue_id}/bearers/traffic
    Status Should Be    200    ${response}

    ${json}=    Set Variable    ${response.json()}

    Should Be True    isinstance(${json}, list)

    FOR    ${item}    IN    @{json}
        Dictionary Should Contain Key    ${item}    ue_id
        Dictionary Should Contain Key    ${item}    bearer_id
        Dictionary Should Contain Key    ${item}    target_bps
    END

Get traffic for UE ${ue_id} bearer ${bearer_id} should fail
    ${response}=   GET On Session    ue_api    /ues/${ue_id}/bearers/${bearer_id}/traffic    expected_status=any
    Should Be True    ${response.status_code} >= 400

Attempt to get traffic without UE ID should fail
    ${response}=   GET On Session    ue_api    /ues//bearers/${VALID_BEARER_ID}/traffic    expected_status=any
    Should Be True    ${response.status_code} >= 400

Set traffic for UE ${ue_id} bearer ${bearer_id} with kbps ${kbps}
    ${headers}=    Prepare Json Headers
    &{body}=       Create Dictionary    protocol=${PROTOCOL}    kbps=${kbps}
    ${response}=   POST On Session    ue_api    /ues/${ue_id}/bearers/${bearer_id}/traffic    json=${body}    headers=${headers}
    Status Should Be    200    ${response}

Verify target bps for UE ${ue_id} bearer ${bearer_id} is ${expected_bps}
    ${response}=   GET On Session    ue_api    /ues/${ue_id}/bearers/${bearer_id}/traffic
    Status Should Be    200    ${response}
    ${json}=    Set Variable    ${response.json()}
    Should Be Equal As Integers    ${json["target_bps"]}    ${expected_bps}
