*** Settings ***
Library               SeleniumLibrary
Library               RequestsLibrary
Library               String
Library               DatabaseLibrary

Suite Setup    Create Session  DR    http://192.168.181.70:8078
*** Variables ***
${DBHost}         192.168.181.70
${DBName}         broadcast
${DBPass}         intership2021
${DBPort}         3306
${DBUser}         intership

*** Test Cases ***

Test API DR Format Benar 
    ${id}=    Membuat UniqID    
    &{data}=    Create dictionary  number=1   status=ACCEPTED    message_id=${id}    destination_id=1    error_code=000
    &{header}=     Create dictionary    Content-Type=application/json
    ${resp}=    POST On Session    DR  /DRReceiverDWS/index.jsp  json=${data}  expected_status=anything    headers=${header}    
    Check Status And Response    status=0    ${resp.text}    200    ${resp}
    Run Keyword If	'${resp.text}' == 'status=0'	Melakukan Pengecekan Databases    ${id}

Test API DR Format Benar Messageid Kosong
    &{data}=    Create dictionary  number=1   status=ACCEPTED    message_id=    destination_id=1    error_code=000
    &{header}=     Create dictionary    Content-Type=application/json
    ${resp}=    POST On Session    DR  /DRReceiverDWS/index.jsp  json=${data}  expected_status=anything    headers=${header}    
    Check Status And Response    status=-3    ${resp.text}    200    ${resp}

Test API DR Format Benar Status Kosong
    ${id}=    Membuat UniqID
    &{data}=    Create dictionary  number=1   status=    message_id=${id}   destination_id=1    error_code=000
    &{header}=     Create dictionary    Content-Type=application/json
    ${resp}=    POST On Session    DR  /DRReceiverDWS/index.jsp  json=${data}  expected_status=anything    headers=${header}    
    Check Status And Response    status=-3    ${resp.text}    200    ${resp}

Test API DR Format Benar And Number Empty or Null
    ${id}=    Membuat UniqID    
    &{data}=    Create dictionary  number=   status=ACCEPTED    message_id=${id}    destination_id=1    error_code=000
    &{header}=     Create dictionary    Content-Type=application/json
    ${resp}=    POST On Session    DR  /DRReceiverDWS/index.jsp  json=${data}  expected_status=anything    headers=${header}    
    Check Status And Response    status=0    ${resp.text}    200    ${resp}
    Run Keyword If	'${resp.text}' == 'status=0'	Melakukan Pengecekan Databases    ${id}

Test API DR Format Benar And destination_id Empty or Null
    ${id}=    Membuat UniqID    
    &{data}=    Create dictionary  number=123   status=ACCEPTED    message_id=${id}    destination_id=   error_code=000
    &{header}=     Create dictionary    Content-Type=application/json
    ${resp}=    POST On Session    DR  /DRReceiverDWS/index.jsp  json=${data}  expected_status=anything    headers=${header}    
    Check Status And Response    status=0    ${resp.text}    200    ${resp}
    Run Keyword If	'${resp.text}' == 'status=0'	Melakukan Pengecekan Databases    ${id}

# Test API DR Witout Content Typr
#     ${id}=    Membuat UniqID    
#     &{data}=    Create dictionary  number=123   status=ACCEPTED    message_id=${id}    destination_id=   error_code=000
#     ${resp}=    POST On Session    DR  /DRReceiverDWS/index.jsp  json=${data}  expected_status=anything   
#     Check Status And Response    status=4   ${resp.text}    400    ${resp}
#     Run Keyword If	'${resp.text}' == 'status=0'	Melakukan Pengecekan Databases    ${id}
    
*** Keywords ***
Melakukan Pengecekan Databases
    [Arguments]    ${uuid}
    Connect To Database    pymysql    ${DBName}    ${DBUser}    ${DBPass}    ${DBHost}    ${DBPort}
    Check If Exists In Database    SELECT * FROM delivery_reports_new WHERE provider_trxid = '${uuid}';
    @{data}=    Query     SELECT * FROM delivery_reports_new WHERE provider_trxid = '${uuid}';
    Log Many    @{data}

Check Status And Response
    [Arguments]    ${body_expt}   ${body_real}   ${status_expt}    ${status_real} 
    Should Be Equal As Strings    ${body_expt}    ${body_real}
    Status Should Be              ${status_expt}  ${status_real}

Membuat UniqID
    ${uuid}=    Evaluate    uuid.uuid4()    modules=uuid 
    ${id}=    Convert To String    ${uuid}
    [Return]    ${id}