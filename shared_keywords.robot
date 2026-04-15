*** Settings ***
Documentation     Shared keywords for testing EPC app
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       http://127.0.0.1:8000
${RESET_ENDPOINT}    /reset


*** Keywords ***
Create API Session
    [Documentation]    Create HTTP session for API calls
    Create Session    ue_api    ${BASE_URL}

Prepare Json Headers
    [Documentation]    Prepare Json request headers
    &{headers}=       Create Dictionary    Content-Type=application/json
    RETURN            ${headers}

Reset API State
    [Documentation]    Reset backend state before each test
    ${response}=      POST On Session    ue_api    ${RESET_ENDPOINT}
