*** Settings ***
Documentation    Required Libraries

Library  SSHLibrary
Library  String
Library  Collections
Library  OperatingSystem
Library  RequestsLibrary

Resource  common_keywords.robot
Resource  test-variables.robot

Suite Setup  TestStart
Suite Teardown  TestEnd

*** Variables ***

*** Keywords ***

TestStart
    [Documentation]  Test initialization

    setup_ssh  ${test_machine_name}  ${username}  #SSH to the jenkins
    ${bbsim_running}=  check_bbsim_status  ${bbsim_no}
    ${bbsim_ip}=  get_bbsim_ip_w_status  ${bbsim_running}  ${bbsim_no}
    ${bbsl_running}=  check_bbsl_status
    create_session_bbsl_w_status  ${bbsl_running}  ${test_node_ip}

TestEnd
    [Documentation]  tests ended

    End HTTP session
    End SSH to TestMachine

*** Test Cases ***

Test1
    [Documentation]  Onos "Ports" check

Test2
    [Documentation]  Onos "Sr-xconnect" check

Test3
    [Documentation]  Onos "Flows -s" check

Test4
    [Documentation]  Onos IP Check after DHCP requests

Test5
    [Documentation]  Flow Check Using downstream p-bit marks

Test6
    [Documentation]  Flow Control after ONT reboot


