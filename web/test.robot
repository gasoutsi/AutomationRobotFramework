*** Settings ***
Library         SeleniumLibrary     implicit_wait=15
Suite Setup    Open Browser For Test
Suite Teardown    Close Browser

*** Variables ***
${url}    https://www.saucedemo.com/
${browser}    headlesschrome
${delay}    3

*** Test Cases ***
Login dengan user yang benar      
    Input User dan Password    standard_user    secret_sauce
    Validasi Success Login
    Go To    ${url}

Login dengan User yang salah
    Input User dan Password    user    pass
    Validasi Failed Login

Login dengan user yang akunya di blok
    Input User dan Password    locked_out_user    pass
    Validasi Failed Login
    
*** Keywords ***
Input User dan Password
    [Arguments]    ${user}    ${pass}
    Input Text    xpath=//*[@id="user-name"]    ${user}
    Input Text    xpath=//*[@id="password"]    ${pass}
    Set Selenium Speed    ${delay}          
    Click Button    Login    

Validasi Success Login
    Page Should Contain    Product
    Capture Page Screenshot

Validasi Failed Login
    Page Should Contain    Epic sadface: Username and password do not match any user in this service
    Capture Page Screenshot

Open Browser For Test
    Open browser    ${url}    ${browser}
    Maximize Browser Window