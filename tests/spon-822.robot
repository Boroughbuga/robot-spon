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

Check_ONOS_ports

    [Documentation]  checks the ports output of ONOS

    setup_ssh  ${test_node_ip}  onos

    log to console  getting ports output from ONOS
    write  ports
    sleep  2s
    ${output}=  read
    close connection

    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \  ${ONT_properties}=  get lines matching regexp  ${output}  ${ONT_serialNumber_${i}}  partial_math=True
    \  should contain  ${ONT_properties}  ${ONT_serialNumber_${i}}
    \  should contain  ${ONT_properties}  state=enabled
    \  should contain  ${ONT_properties}  adminState=enabled
    \  @{ONT_properties}=  split string  ${ONT_properties}
    \  ${ONT_port}=  set variable  @{ONT_properties}[0]
    \  ${ONT_port}=  fetch from right  ${ONT_port}  =
    \  ${ONT_port}=  fetch from left  ${ONT_port}  ,
    \  log to console  ONT:${ONT_serialNumber_${i}} is assigned to port:${ONT_port}

    should contain  ${output}  port=65536
    log to console  NNI port: 65536 is set
    @{OLT_ports}=  split string  ${output}  id=of:00000000000000

    :FOR  ${i}  IN RANGE  ${num_of_olt}
    \  loop_active_olt_ports  @{OLT_ports}[${i}]  @{olt_ports_list}  @{ports_per_olt}[${i}]

loop_active_olt_ports
    [Documentation]  to create a nested loops
    [Arguments]  ${list1}  @{list2}  ${list3}

    :FOR  ${i}  IN RANGE  @{list3}
    \  should contain  ${list1}  port=@{active_OLT_ports}[${i}], state=enabled
    \  log to console  OLT port: @{active_OLT_ports}[${i}] is set

check_active_olt_ports_srx

    [Documentation]  get the ports for each olt

    @{olt_ports_list}=  create list
    set global variable  @{olt_ports_list}  @{olt_ports_list}
    @{ports_per_olt}=  create list
    set global variable  @{ports_per_olt}  @{ports_per_olt}

    setup_ssh  ${test_node_ip}  onos

    log to console  getting sr-xconnect output from ONOS
    write  sr-xconnect
    sleep  2s
    ${output}=  read
    close connection

    :FOR  ${i}  IN RANGE  ${num_of_olt}
    \  ${j}=  set variable  ${i}
    \  ${j}=  evaluate  ${j}+2
    \  ${temp}=  get lines matching regexp  ${output}  deviceId=of:000000000000000${j}  partial_math=True
    \  @{temp}=  split to lines  ${temp}
    \  ${temp}=  fetch from left  ${temp}  ]
    \  ${temp}=  fetch from right  ${temp}  [
    \  @{temp_list}=  split string  ${temp}  ,${space}
    \  ${temp_length}=  get length  ${temp_list}
    \  add list to list  @{olt_ports_list}  @{temp_list}
    \  add list to list  @{ports_per_olt}  @{temp_length}

add list to list
    [Documentation]  appends a list to a list varible
    [Arguments]  @{list1}  @{list2}

    ${list_length}=  get length  ${list2}
    :FOR  ${i}  IN RANGE  ${list_length}
    \  append to list  ${list1}  @{list2}[${i}]

Check_ONOS_sr-xconnect

    [Documentation]  checks the sr-xconnect output of ONOS

    #number of lines that should be printed out
    ${srx_expected_line_count}=  evaluate  ${num_of_services}*${num_of_olt}

    setup_ssh  ${test_node_ip}  onos

    log to console  getting sr-xconnect output from ONOS
    write  sr-xconnect
    sleep  2s
    ${output}=  read
    close connection

    ${srx_lines}=  get lines matching regexp  ${output}  XconnectDesc  partial_math=True
    ${srx_line_count}=  get line count  ${srx_lines}
    should be equal as strings  ${srx_expected_line_count}  ${srx_line_count}

    :FOR  ${i}  IN RANGE  ${num_of_services}
    \  ${temp}=  get lines matching regexp  ${srx_lines}  vlanID=${vlan_id_${i}}  partial_math=True
    \  ${temp}=  get line count  ${temp}
    \  should be equal as strings  ${temp}  2
    \  log to console  sr-xconnect is true for vlanID=${vlan_id_${i}}

    log to console  srx-connect output is correct for current setup


*** Test Cases ***

Test1
    [Documentation]  Onos "Ports" check

    check_active_olt_ports_srx
    Check_ONOS_ports

Test2
    [Documentation]  Onos "Sr-xconnect" check

    Check_ONOS_sr-xconnect

Test3
    [Documentation]  Onos "Flows -s" check

Test4
    [Documentation]  Onos IP Check after DHCP requests

Test5
    [Documentation]  Flow Check Using downstream p-bit marks

Test6
    [Documentation]  Flow Control after ONT reboot

Testt

#    ${a}=  set variable  XconnectDesc{key=XconnectKey{deviceId=of:0000000000000002, vlanId=1546, rgMac=A4:23:05:00:00:00}, ports=[1, 72]}
#    ${c}=  fetch from left  ${a}  ]
#    ${c}=  fetch from right  ${c}  [
#    @{b}=  split string  ${c}  ,${space}
#    log to console  ${c}
#    log to console  @{b}[0]
#    log to console  @{b}[1]
#
#    @{olt_ports_list}=  create list
#    set global variable  @{olt_ports_list}  @{olt_ports_list}
#    append to list  ${olt_ports_list}  1
#    log to console  @{olt_ports_list}[0]