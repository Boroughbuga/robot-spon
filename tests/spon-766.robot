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
    create_session_bbsl_w_status  ${bbsl_running}  ${test_node_ip}  ${bbsl_port}

TestEnd
    [Documentation]  tests ended
    End HTTP session
    End SSH to TestMachine


*** Test Cases ***

test1
    [Documentation]  Voltha Flows OLT
    [Tags]  Flowtest

    setup_ssh  ${test_machine_name}  voltha

    write  devices
    sleep  2s
    ${output}=  read
    ${output}=  remove string  ${output}  |

    ${columns}=  get lines matching regexp  ${output}  serial_number  partial_math=True
    @{columns}=  split string  ${columns}

    ${OLT_properties}=  get lines matching regexp  ${output}  ${OLT_serialNumber}  partial_math=True
    @{OLT_properties}=  split string  ${OLT_properties}
    ${OLT_id}=  set variable  @{OLT_properties}[0]

    write  device ${OLT_id}
    write  flows
    sleep  2s
    ${output}=  read
    ${output}=  remove string  ${output}  |

    log to console  \n ====\n${output}\n====\n

#flowları check et
    write  q
    close connection

test2
    [Documentation]  Voltha Flows ONT
    [Tags]  Flowtest

    setup_ssh  ${test_machine_name}  voltha

    write  devices
    sleep  2s
    ${output}=  read
    ${output}=  remove string  ${output}  |


    ${ONT_properties}=  get lines matching regexp  ${output}  ${ONT_serialNumber}  partial_math=True
    @{ONT_properties}=  split string  ${ONT_properties}
    ${ONT_id}=  set variable  @{ONT_properties}[0]

    write  device ${ONT_id}
    write  flows
    sleep  2s
    ${output}=  read
    ${output}=  remove string  ${output}  |
    log to console  \n ====\n${output}\n====\n

#
# flowları check et
# multiple olt ve ont senaryosu
# basta mı hepsi tek te mi?
#
    write  q
    close connection

test3
    [Documentation]  Onos Check ports, update ONT port
    [Tags]  Flowtest

    ${ONT_port}=  get_ont_port_onos  ${test_machine_name}  ${ONT_serialNumber}

    ${test_variables}=  OperatingSystem.Get File  test-variables.robot     # convert json to a dictionary variable
    ${test_variables}=  replace string  ${test_variables}  \${subscriber_uniPortNumber}=${SPACE}${SPACE}${subscriber_uniPortNumber}  \${subscriber_uniPortNumber}=${SPACE}${SPACE}${ONT_port}
    OperatingSystem.Create File  test-variables.robot  content=${test_variables}

test4
    [Documentation]  Onos Check flows
    [Tags]  Flowtest
    setup_ssh  ${test_machine_name}  onos

    write  flows -s
    sleep  2s
    ${output}=  read

#
# flowları check et

    close connection

test5
    [Documentation]  Onos - Check sr-xconnect output
    [Tags]  Flowtest
    setup_ssh  ${test_machine_name}  onos

    write  sr-xconnect
    sleep  2s
    ${output}=  read

#
# flowları check et

    close connection

test6
    [Documentation]  Onos - Check volt-suscribers output
    [Tags]  Flowtest
    setup_ssh  ${test_machine_name}  onos

    write  volt-suscribers
    sleep  2s
    ${output}=  read

#
# flowları check et

    close connection

testtest

    ${test}=  get_num_of_olt
    ${test}=  get_num_of_ont