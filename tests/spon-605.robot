*** Settings ***
Documentation    Required Libraries

Library  SSHLibrary
Library  String
Library  Collections
Library  OperatingSystem
Library  RequestsLibrary

Resource  common_keywords.robot

*** Variables ***
${bbslport}=  32000
${test_machine_name}=  192.168.31.181
${username}=  cord
*** Test Cases ***

Test1:EmptyChasisList  #check chasis list, pass if list is empty.
    [Tags]    Sprint6


    setup  ${test_machine_name}  ${username}   #SSH to the jenkins

    ${bbsl_port}=  get_BBSL_Port    #get BBSL port from kubectlsvc

    #print a warning if the ports isnt expected default port of 32000
    run keyword if  ${bbsl_port}!=32000  log to console  \n"""""""""Warning:"""""""""\nbbsl port isn't default port: 32000\n""""""""""""""""""""""""""

*** Keywords ***
