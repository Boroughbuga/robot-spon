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

Get_vcli_device_id
    [Documentation]  gets the flows output from device with given serial number
    [Arguments]  ${test_node_ip}  ${device_id}

    setup_ssh  ${test_node_ip}  voltha
    write  devices
    sleep  2s
    ${output}=  read
    ${output}=  remove string  ${output}  |

    ${columns}=  get lines matching regexp  ${output}  serial_number  partial_math=True
    @{columns}=  split string  ${columns}
    ${id_index}=  get index from list  ${columns}  id

    ${properties}=  get lines matching regexp  ${output}  ${device_id}  partial_math=True
    @{properties}=  split string  ${properties}
    ${id}=  set variable  @{properties}[${id_index}]
    close connection

    [Return]  ${id}

Get_vcli_flows
    [Documentation]  gets the flows output from device with given serial number
    [Arguments]  ${test_node_ip}  ${id}

    setup_ssh  ${test_node_ip}  voltha
    write  device ${id}
    write  flows
    sleep  2s
    ${output}=  read
    ${device_flows}=  remove string  ${output}  |
    close connection

    [Return]  ${device_flows}

*** Test Cases ***

test1
    [Documentation]  Voltha Flows OLT, check hsi flows
    [Tags]  Flowtest

    ${OLT_id}=  get_vcli_device_id  ${test_node_ip}  ${OLT_serialNumber}
    ${olt_flows}=  get_vcli_flows  ${test_node_ip}  ${OLT_id}
    ${ONT_id}=  get_vcli_device_id  ${test_node_ip}  ${ONT_serialNumber}
    ${ont_flows}=  get_vcli_flows  ${test_node_ip}  ${ONT_id}

    log to console  \n olt_id: ${OLT_id} \n ont_id: ${ONT_id}

    #start checking flows
#    ${ont_columns}=  get lines matching regexp  ${ont_flows}  table_id  partial_math=True
#    @{ont_columns}=  split string  ${ont_columns}
#    ${table_index}=  get index from list  ${ont_columns}  in_port

    ${ONT_port}=  get_ont_port_onos  ${test_node_ip}  ${ONT_serialNumber}
    Update_variables_in_test_variables  \${subscriber_uniPortNumber}  ${subscriber_uniPortNumber}  ${ONT_port}

    #ont flows
    ${hsi_flow_1}=  get lines matching regexp  ${ont_flows}  ${subscriber_uniPortNumber}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_defaultVlan}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_usctagPriority}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${ONT_uplink_port_vcli}  partial_math=True
    ${line_count}=  get line count  ${hsi_flow_1}
    should be equal as strings  ${line_count}  1
    ${hsi_flow_4}=  get lines matching regexp  ${ont_flows}  ${ONT_uplink_port_vcli}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_defaultVlan}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}Yes${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_uniPortNumber}  partial_math=True
    ${line_count}=  get line count  ${hsi_flow_4}
    should be equal as strings  ${line_count}  1
    #olt flows
    ${hsi_flow_2}=  get lines matching regexp  ${olt_flows}  ${subscriber_uniPortNumber}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_usctagPriority}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_stag}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_usstagPriority}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}8100${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${OLT_uplink_port_vcli}  partial_math=True
    ${line_count}=  get line count  ${hsi_flow_2}
    should be equal as strings  ${line_count}  1
    ${hsi_flow_3}=  get lines matching regexp  ${olt_flows}  ${OLT_uplink_port_vcli}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_stag}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_usstagPriority}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}Yes  partial_math=True
    ${line_count}=  get line count  ${hsi_flow_3}
    should be equal as strings  ${line_count}  8

#    ${hsi_flow_1}=  get lines matching regexp  ${ont_flows}  ${ONT_port}  partial_math=True
#    ${hsi_flow_1}=  get lines matching regexp  ${hsi_flow_1}  ${subscriber_services_defaultVlan}  partial_math=True
#    ${hsi_flow_1}=  get lines matching regexp  ${hsi_flow_1}  ${subscriber_services_ctag}  partial_math=True
#    ${hsi_flow_1}=  get lines matching regexp  ${hsi_flow_1}  ${subscriber_services_usctagPriority}  partial_math=True
#    ${hsi_flow_1}=  get lines matching regexp  ${hsi_flow_1}  ${ONT_uplink_port_vcli}  partial_math=True

    log to console  HSI flows are correct

# | table_id | priority |    cookie | in_port | vlan_vid |           dst_mac | set_vlan_vid | set_vlan_pcp | pop_vlan | push_vlan | output | write-metadata | meter |
# |        0 |     1000 | ~2539c725 |      16 |       35 |                   |          101 |            6 |          |           |    100 |   274877972480 |     1 |
# 16     101             6                          100

#    close connection

test2
    [Documentation]  Voltha Flows ONT
    [Tags]  Flowtest

    setup_ssh  ${test_node_ip}  voltha

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

    ${ONT_port}=  get_ont_port_onos  ${test_node_ip}  ${ONT_serialNumber}
    Update_variables_in_test_variables  \${subscriber_uniPortNumber}  ${subscriber_uniPortNumber}  ${ONT_port}


test4
    [Documentation]  Onos Check flows
    [Tags]  Flowtest
    setup_ssh  ${test_node_ip}  onos

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
