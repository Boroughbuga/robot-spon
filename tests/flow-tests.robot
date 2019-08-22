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

    log to console  \nsetting up test
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

pretest

    ${temp}=  check_bbsim_status  ${bbsim_no}
    Update_variables_in_test_variables  \${bbsim_running}  ${bbsim_running}  ${temp}

test1
    [Documentation]  check hsi flows
    [Tags]  Flowtest
    @{OLT_id_list}=  create list
    @{OLT_flow_list}=  create list
    @{ONT_id_list}=  create list
    @{ONT_flow_list}=  create list
    @{ONT_port_list}=  create list
    @{hsi_flow_1_list}=  create list
    @{hsi_flow_4}=  create list

    :FOR  ${i}  IN RANGE  ${num_of_olt}
    \  ${OLT_id}=  get_vcli_device_id  ${test_node_ip}  ${OLT_serialNumber_${i}}
    \  ${OLT_flows}=  get_vcli_flows  ${test_node_ip}  ${OLT_id}
    \  append to list  ${OLT_id_list}  ${OLT_flows}
    \  append to list  ${OLT_flow_list}  ${OLT_flows}
    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \  ${ONT_port}=  get_ont_port_onos  ${test_node_ip}  ${ONT_serialNumber_${i}}
    \  ${ONT_id}=  get_vcli_device_id  ${test_node_ip}  ${ONT_serialNumber_${i}}
    \  ${ONT_flows}=  get_vcli_flows  ${test_node_ip}  ${ONT_id}
    \  append to list  ${ONT_id_list}  ${ONT_id}
    \  append to list  ${ONT_flow_list}  ${ONT_flows}
    \  append to list  ${OLT_id_list}  ${ONT_port}
    \  log to console  \n ont_id: ${ONT_id}
    #ont flows
    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \  ${hsi_flow_1}=  get lines matching regexp  @{ONT_flow_list}[${i}]  @{ONT_port_list}[${i}]${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_defaultVlan_${i}}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag_${i}}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_usctagPriority_${i}}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${ONT_uplink_port_vcli_${i}}  partial_math=True
    \  ${line_count}=  get line count  ${hsi_flow_1}
    \  should be equal as strings  ${line_count}  1
    \  ${hsi_flow_4}=  get lines matching regexp  @{ONT_flow_list}[${i}]  ${ONT_uplink_port_vcli_${i}}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag_${i}}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_defaultVlan_${i}}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}Yes${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}@{ONT_port_list}[${i}]  partial_math=True
    \  ${line_count}=  get line count  ${hsi_flow_4}
    \  should be equal as strings  ${line_count}  1
    #olt flows
#    ${j}=  Set Variable  0
#    :FOR  ${i}  IN RANGE  ${num_of_ont}
#    \  ${hsi_flow_2_${i}}=  get lines matching regexp  ${olt_flows_${j}}  ${ONT_port_${i}}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag_${i}}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_usctagPriority_${i}}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_stag_${i}}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_usstagPriority_${i}}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}8100${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${OLT_uplink_port_vcli_${i}}  partial_math=True
#    \  ${line_count}=  get line count  ${hsi_flow_2}
#    \  should be equal as strings  ${line_count}  1
#    \  set global variable  ${hsi_flow_2_${i}}  ${hsi_flow_2_${i}}
#    \  ${hsi_flow_3_${i}}=  get lines matching regexp  ${olt_flows_${j}}  ${OLT_uplink_port_vcli_${i}}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_stag_${i}}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag_${i}}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag_${i}}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_usstagPriority_${i}}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}Yes  partial_math=True
#    \  ${line_count}=  get line count  ${hsi_flow_3}
#    \  should be equal as strings  ${line_count}  8
#    \  set global variable  ${hsi_flow_3_${i}}  ${hsi_flow_3_${i}}
#    \  ${j}=  evaluate  ${j}+1
#    :FOR  ${i}  IN RANGE  ${num_of_ont}
#    \  log to console  \n full flows:
#    \  log to console  \n ont to olt: ${hsi_flow_1_${i}}
#    \  log to console  \n olt to bng: ${hsi_flow_2_${i}}
#    \  log to console  \n bng to olt: ${hsi_flow_3_${i}}
#    \  log to console  \n ont to rg : ${hsi_flow_4_${i}}
#    \  log to console  \n HSI flows are correct

    [Teardown]  run keyword if test failed  log to console  \nTest failed: HSI flows are missing or not complete

test2
    [Documentation]  check VOIP flows
    [Tags]  Flowtest

    ${ONT_port}=  get_ont_port_onos  ${test_node_ip}  ${ONT_serialNumber}

    ${OLT_id}=  get_vcli_device_id  ${test_node_ip}  ${OLT_serialNumber}
    ${olt_flows}=  get_vcli_flows  ${test_node_ip}  ${OLT_id}
    ${ONT_id}=  get_vcli_device_id  ${test_node_ip}  ${ONT_serialNumber}
    ${ont_flows}=  get_vcli_flows  ${test_node_ip}  ${ONT_id}

    log to console  \n olt_id: ${OLT_id} \n ont_id: ${ONT_id}

    #ont flows
    ${voip_flow_1}=  get lines matching regexp  ${ont_flows}  ${ONT_port}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag_voip}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag_voip}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_usctagPriority_voip}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${ONT_uplink_port_vcli}  partial_math=True
    ${line_count}=  get line count  ${voip_flow_1}
    should be equal as strings  ${line_count}  1
    ${voip_flow_4}=  get lines matching regexp  ${ont_flows}  ${ONT_uplink_port_vcli}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag_voip}${SPACE}${SPACE}${subscriber_macAddress}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag_voip}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}Yes${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${ONT_port}  partial_math=True
    ${line_count}=  get line count  ${voip_flow_4}
    should be equal as strings  ${line_count}  1

    #olt flows
    ${voip_flow_2}=  get lines matching regexp  ${olt_flows}  ${ONT_port}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag_voip}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_usctagPriority_voip}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_stag_voip}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_usstagPriority_voip}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}8100${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${OLT_uplink_port_vcli}  partial_math=True
    ${line_count}=  get line count  ${voip_flow_2}
    should be equal as strings  ${line_count}  1
    ${voip_flow_3}=  get lines matching regexp  ${olt_flows}  ${OLT_uplink_port_vcli}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_stag_voip}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag_voip}${SPACE}${SPACE}${ONT_mac}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag_voip}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_usstagPriority_voip}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}Yes  partial_math=True
    ${line_count}=  get line count  ${voip_flow_3}
    should be equal as strings  ${line_count}  8
    ${voip_flow_5}=  get lines matching regexp  ${olt_flows}  ${ONT_port}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${subscriber_services_ctag_voip}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}800  partial_math=True
    ${line_count}=  get line count  ${voip_flow_5}
    should be equal as strings  ${line_count}  1

    log to console  \n full flows:
    log to console  \n ont to olt: ${voip_flow_1}
    log to console  \n olt to bng: ${voip_flow_2}
    log to console  \n nbg to olt: ${voip_flow_3}
    log to console  \n ont to rg : ${voip_flow_4}
    log to console  \n dhcp flow : ${voip_flow_5}
    log to console  \n VOIP flows are correct

    [Teardown]  run keyword if test failed  log to console  \nTest failed: VOIP flows are missing or not complete

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
