*** Settings ***

Library  SSHLibrary
Library  String
Library  Collections
Library  OperatingSystem
Library  RequestsLibrary

*** Keywords ***

    #============================
    #Connection related keywords:
    #============================

SSH to TestMachine
# ssh in to remote machine

    [Arguments]  ${ip_address}  ${port}  ${id}  ${psswd}
    [Documentation]  ssh connection setup

    open connection  ${ip_address}  port=${port}
    ${output}=  login  ${id}  ${psswd}
    log to console  \n ssh connection successful

End SSH to TestMachine

    [Documentation]  tests ended -> closing connections to remote machine
    close all connections
    log to console  \n ssh connection aborted

End HTTP session

    [Documentation]  tests ended -> closing connections to remote machine
    delete all sessions
    log to console  \nHTTP session ended

Setup_ssh
    [Arguments]  ${ip}  ${username}
#read json file and create a dictionary variable from json
    ${jsonfile}=  OperatingSystem.Get File  ../json-files/authentication-jsons/authentication.json     # convert json to a dictionary variable
    ${authentication}=  Evaluate  json.loads('''${jsonfile}''')  json

    &{machine_name}=  get from dictionary  ${authentication}  ${ip}
    &{profile}=  get from dictionary  ${machine_name}  ${username}

    ${port}=  get from dictionary  ${profile}  port
    ${id}=  get from dictionary  ${profile}  username
    ${psswd}=  get from dictionary  ${profile}  password
    ${ip}=  get from dictionary  ${machine_name}  ip

    log to console  \n trying to connect: ${id}@${ip}:${port}
    ssh to testmachine  ${ip}  ${port}  ${id}  ${psswd}
    sleep  4s

    #============================
    #BBSL related keywords:
    #============================

get_BBSL_Port
    [Documentation]  #get the port of bbsl service from target machine, warns if it isn't the default port:32000

    write  kubectl get svc --all-namespaces | grep "bbsl-service" | awk '{print $6}'
    sleep  6s
    ${bbsl_port}=  read
    ${bbsl_port}=  get lines matching regexp  ${bbsl_port}  9090  partial_math=True
    ${bbsl_port}=  get substring  ${bbsl_port}  5  10
    log to console  \nbbsl port: "${bbsl_port}"
    sleep  2s
    #print a warning if the ports isnt expected default port of 32000
    run keyword if  ${bbsl_port}!=32000  log to console  \n"""""""""Warning:"""""""""\nbbsl port isn't default port: 32000\n""""""""""""""""""""""""""
    set global variable  ${bbslport}  ${bbslport}
    [Return]  ${bbsl_port}

check_bbsl_status
    [Documentation]  #returns true if there is a bssl pod

    write  kubectl get svc --all-namespaces | grep "bbsl" | awk '{print $2}'
    sleep  2s
    ${output}=  read
    sleep  2s
    ${bbsl_running}=  run keyword and return status  should contain  ${output}  bbsl-service
    log to console  \n using bbsl?= ${bbsl_running}

    [Return]  ${bbsl_running}

Create_session_BBSL
    [Documentation]  #creates the HTTP session for BBSL tests
    [Arguments]  ${test_node_ip}  ${bbsl_port}

    create session  bbsl-api  http://${test_node_ip}:${bbsl_port}
    &{headers}=  create dictionary  Content-Type=application/json
    set global variable  ${headers}  &{headers}
    log to console  \nHTTP session started

    [Return]  ${headers}  ${bbslport}

Create_session_BBSL_w_status
    [Documentation]  #creates the HTTP session for BBSL tests if BBSL status is TRUE
    [Arguments]  ${bbsl_running}  ${test_node_ip}

    ${headers}=  set variable  null
    set global variable  ${headers}  ${headers}
    ${bbsl_port}=  run keyword if  "${bbsl_running}" == "True"  get_BBSL_Port
    set global variable  ${bbsl_port}  ${bbsl_port}
    run keyword if  "${bbsl_running}" == "True"
    ...  create_session_bbsl  ${test_node_ip}  ${bbsl_port}
    ...  ELSE  log to console  BBSL not running, aborted HTTP creation

Update_OLT_add.json
    [Arguments]  ${olt_no}
    ${jsonfile}=  create dictionary  ipAddress=${OLT_ip_${olt_no}}  port=${OLT_port_${olt_no}}  name=${OLT_name_${olt_no}}  clli=${OLT_clli_${olt_no}}  oltDriver=${oltDriver_${olt_no}}  deviceType=${deviceType_${olt_no}}
    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/OLT_add_${olt_no}.json  content=${json}

Update_chassis_add_and_delete.json

    ${jsonfile}=  create dictionary  clli=${clli}  rack=${${rack}}  shelf=${${shelf}}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/chassis_add.json  content=${json}
    OperatingSystem.Create File  ../json-files/bbsl-jsons/chassis_delete.json  content=${json}

Update_ONT_provision.json
    [Arguments]  ${ont_no}  ${ont_number}
    Update_variables_in_test_variables  \${ontNumber_${ont_no}}  ${ontNumber_${ont_no}}  ${ontNumber}
    ${jsonfile}=  create dictionary  serialNumber=${ONT_serialNumber_${ont_no}}  clli=${ONT_clli_${ont_no}}  slotNumber=${${ONT_slotNumber_${ont_no}}}  ponPortNumber=${${ONT_ponPortNumber_${ont_no}}}  ontNumber=${ontNumber}
    #${ontNumber_${ont_no}}
    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/ONT_provision_${ont_no}.json  content=${json}

Update_ONT_disable.json
    [Arguments]  ${ont_no}
    ${jsonfile}=  create dictionary  serialNumber=${ONT_serialNumber_${ont_no}}
    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/ONT_disable_${ont_no}.json  content=${json}

Update_ONT_enable.json
    [Arguments]  ${ont_no}
    ${jsonfile}=  create dictionary  serialNumber=${ONT_serialNumber_${ont_no}}
    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/ONT_enable_${ont_no}.json  content=${json}

Update_Tech_profile_add.json

    [Arguments]  ${Tech_profile_no}

    ${tech_profile_dictionary}=  create dictionary  name=${d_tech_profile_name_${Tech_profile_no}}  data=${tech_profile_data_${Tech_profile_no}}
    set global variable  ${tech_profile_dictionary_${Tech_profile_no}}  ${tech_profile_dictionary}
    ${json}=  evaluate  json.dumps(${tech_profile_dictionary})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/Tech_profile_add_${Tech_profile_no}.json  content=${json}

Update_Speed_profile_add.json

    [Arguments]  ${Speed_profile_no}

    ${speed_profile_dictionary}=  create dictionary  name=${speed_profile_name_${Speed_profile_no}}  data=${speed_profile_data_${Speed_profile_no}}
    set global variable  ${speed_profile_dictionary_${Speed_profile_no}}  ${speed_profile_dictionary}
    ${json}=  evaluate  json.dumps(${speed_profile_dictionary})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/speed_profile_add_${Speed_profile_no}.json  content=${json}

Update_subscriber_provision.json
    [Arguments]  ${subscriber_no}  ${ONT_port}  ${ont_number}
    Update_variables_in_test_variables  \${ont_port_no_${subscriber_no}}  ${ont_port_no_${subscriber_no}}  ${ONT_port}
    Update_variables_in_test_variables  \${ontNumber_${subscriber_no}}  ${ontNumber_${subscriber_no}}  ${ontNumber}
    ${subscriber_provision_dictionary}=  set variable  {"userIdentifier" : "${subscriber_userIdentifier_${subscriber_no}}", "macAddress" : "${subscriber_macAddress_${subscriber_no}}", "nasPortId" : "${subscriber_nasPortId_${subscriber_no}}", "clli" : "${subscriber_clli_${subscriber_no}}", "slotNumber" : ${Subscriber_slotNumber_${subscriber_no}}, "portNumber" : ${subscriber_portNumber_${subscriber_no}}, "ontNumber" : ${ontNumber}, "uniPortNumber" : ${ONT_port}, "services" : ${subscriber_services_${subscriber_no}}}
    log to console  ${subscriber_provision_dictionary}
    ${json}=  evaluate  json.dumps(${subscriber_provision_dictionary})  json
    #${json}=  remove string  ${json}  \\
    OperatingSystem.Create File  ../json-files/bbsl-jsons/subscriber_provision_${subscriber_no}.json  content=${json}

Update_ONT_delete.json

    [Arguments]  ${ont_no}
    ${jsonfile}=  create dictionary  serialNumber=${ONT_serialNumber_${ont_no}}
    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/ONT_delete_${ont_no}.json  content=${json}

Update_subscriber_delete.json

    [Arguments]  ${subscriber_no}
    ${subscriber_delete_dictionary}=  set variable  {"userIdentifier" : "${subscriber_userIdentifier_${subscriber_no}}", "services" : ["HSIA","VOIP"]}
    ${json}=  evaluate  json.dumps(${subscriber_delete_dictionary})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/subscriber_delete_${subscriber_no}.json  content=${json}

Update_OLT_delete.json
    [Arguments]  ${device_id}  ${olt_no}

    ${jsonfile}=  create dictionary  ipAddress=${OLT_ip_${olt_no}}  port=${OLT_port_${olt_no}}  name=${OLT_name_${olt_no}}  clli=${OLT_clli_${olt_no}}  oltDriver=${oltDriver_${olt_no}}  deviceType=${deviceType_${olt_no}}  deviceId=${device_id}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/OLT_delete_${olt_no}.json  content=${json}

    #============================
    #BBSIM related keywords:
    #============================

check_bbsim_status
    [Documentation]  returns true if there is a bbsim pod running
    [Arguments]  ${bbsim_no}

    sleep  2s
    write  kubectl get svc --all-namespaces | grep "bbsim${bbsim_no}" | awk '{print $2}'
    sleep  6s
    ${output}=  read
    sleep  2s
    ${bbsim_running}=  run keyword and return status  should contain  ${output}  bbsim
    log to console  \n bbsim active?= ${bbsim_running}

    [Return]  ${bbsim_running}

get_bbsim_ip
    [Documentation]  get the IP of BBSL from kubectl get svc
    [Arguments]  ${bbsim_no}
    write  kubectl get svc --all-namespaces | grep "bbsim${bbsim_no}" | awk '{print $4}'
    sleep  2s
    ${bbsim_ip}=  read
    sleep  2s
    ${bbsim_ip}=  get lines matching regexp  ${bbsim_ip}  10.  partial_math=True

    log to console  \nbbsim${bbsim_no} ip: "${bbsim_ip}"
    [Return]  ${bbsim_ip}

get_bbsim_ip_w_status
    [Documentation]  get the IP of BBSL from kubectl get svc
    [Arguments]  ${bbsim_running}  ${bbsim_no}

    write  kubectl get svc --all-namespaces | grep "bbsim${bbsim_no}" | awk '{print $4}'
    sleep  2s
    ${output}=  read
    sleep  2s
    ${bbsim_ip}=  run keyword if  "${bbsim_running}" == "True"  get lines matching regexp  ${output}  10.  partial_math=True
    set global variable  ${bbsim_ip}  ${bbsim_ip}
    log to console  \nbbsim${bbsim_no} ip: "${bbsim_ip}"

    [Return]  ${bbsim_ip}

    #============================
    #ONT/OLT related keywords:
    #============================

Get_num_of_OLT

    [Documentation]  get number of OLT used in test

    set global variable  ${Num_of_OLT}  0
    FOR  ${i}  IN RANGE  999
        ${status}=  run keyword and return status  variable should exist  ${OLT_serialNumber_${i}}
        Exit For Loop IF  "${status}" == "False"
        ${Num_of_OLT}=  evaluate  ${Num_of_OLT}+1
    END
    log to console  \nnumber of OLTs: ${Num_of_OLT}

    [Return]  ${Num_of_OLT}

Get_num_of_ONT

    [Documentation]  get number of ONT used in test

    set global variable  ${Num_of_ONT}  0
    FOR  ${i}  IN RANGE  999
        ${status}=  run keyword and return status  variable should exist  ${ONT_serialNumber_${i}}
        Exit For Loop IF  "${status}" == "False"
        ${Num_of_ONT}=  evaluate  ${Num_of_ONT}+1
    END
    log to console  \nnumber of ONTs: ${Num_of_ONT}

    [Return]  ${Num_of_ONT}

Get_ONT_port_ONOS

    [Documentation]  returns the ONT port from ONOS ports output
    [Arguments]  ${test_machine_name}  ${ONT_serialNumber}

    setup_ssh  ${test_node_ip}  onos

    log to console  getting ONT port from ONOS
    write  ports
    sleep  2s
    ${output}=  read

    ${ONT_properties}=  get lines matching regexp  ${output}  ${ONT_serialNumber}  partial_math=True
    should contain  ${ONT_properties}  ${ONT_serialNumber}
    @{ONT_properties}=  split string  ${ONT_properties}
    ${ONT_port}=  set variable  @{ONT_properties}[0]
    ${ONT_port}=  fetch from right  ${ONT_port}  =
    ${ONT_port}=  fetch from left  ${ONT_port}  ,

    [Return]  ${ONT_port}

Get_vcli_device_id
    [Documentation]  gets the device id from voltha using serial number
    [Arguments]  ${test_node_ip}  ${device_serial}

    setup_ssh  ${test_node_ip}  voltha
    log to console  \ngetting device id for serial: ${device_serial}
    write  devices
    sleep  2s
    ${output}=  read
    ${output}=  remove string  ${output}  |

    ${columns}=  get lines matching regexp  ${output}  serial_number  partial_math=True
    @{columns}=  split string  ${columns}
    ${id_index}=  get index from list  ${columns}  id

    ${properties}=  get lines matching regexp  ${output}  ${device_serial}  partial_math=True
    @{properties}=  split string  ${properties}
    ${id}=  set variable  @{properties}[${id_index}]
    close connection

    [Return]  ${id}

Get_vcli_flows
    [Documentation]  gets the flows output from device with given serial number
    [Arguments]  ${test_node_ip}  ${id}

    setup_ssh  ${test_node_ip}  voltha
    log to console  getting flows for id: ${id}
    write  device ${id}
    write  flows
    sleep  2s
    ${output}=  read
    ${device_flows}=  remove string  ${output}  |
    close connection

    [Return]  ${device_flows}

get_ont_number_bbsl

    [Documentation]  gets ont number for each discovered ONT from BBSL inventory output

    @{ont_number_list}=  create list
    set global variable  @{ont_number_list}  @{ont_number_list}
    @{ont_bbsl_serial_list}=  create list
    set global variable  @{ont_bbsl_serial_list}  @{ont_bbsl_serial_list}

    @{tempser}=  create list
    @{tempontnum}=  create list
    set global variable  @{tempser}  @{tempser}
    set global variable  @{tempontnum}  @{tempontnum}

    ${response}=  get request  bbsl-api  /inventory/all
    should be equal as strings  ${response.status_code}  200
    # log to console  ${response.json()[0]["olts"][0]["oltPorts"][0]["ontDevices"][0]["ontNumber"]}
    @{list}=  Evaluate  filter(lambda x: x['ontDevices'] != [], ${response.json()[0]["olts"][0]["oltPorts"]})
    @{list2}=  get from dictionary  @{list}[0]  ontDevices

    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \  ${ont_bbsl_serial}=   get from dictionary  @{list2}[${i}]  serialNumber
    \  ${ont_number}=  get from dictionary  @{list2}[${i}]  ontNumber
    \  append to list  ${ont_number_list}  ${ont_number}
    \  append to list  ${ont_bbsl_serial_list}  ${ont_bbsl_serial}

    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \  swap_ontnumber  ${i}
    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \  insert into list  ${ont_bbsl_serial_list}  ${i}  @{tempser}[${i}]
    \  insert into list  ${ont_number_list}  ${i}  @{tempontnum}[${i}]

    [Return]  @{ont_number_list}

swap_ontnumber
    [Documentation]  a keyword to do a nested loop in get ont number
    [Arguments]  ${ontno}
    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \  ${status}=  run keyword and return status  should be equal as strings  @{ont_bbsl_serial_list}[${i}]  ${ONT_serialNumber_${ontno}}
    \  run keyword if  "${status}" == "True"  set global variable  ${tempser_${ontno}}  @{ont_bbsl_serial_list}[${i}]
    \  run keyword if  "${status}" == "True"  set global variable  ${tempontnum_${ontno}}  @{ont_number_list}[${i}]
    \  run keyword if  "${status}" == "True"  insert into list  ${tempser}  ${ontno}  @{ont_bbsl_serial_list}[${i}]
    \  run keyword if  "${status}" == "True"  insert into list  ${tempontnum}  ${ontno}  @{ont_number_list}[${i}]

update_subscriber_provision_w_ontnumber&port
    @{ONT_id_list}=  create list
    @{ONT_port_list}=  create list
    @{OLT_id_list}=  create list

    set global variable  @{ONT_id_list}  @{ONT_id_list}
    set global variable  @{ONT_port_list}  @{ONT_port_list}
    set global variable  @{OLT_id_list}  @{OLT_id_list}

    :FOR  ${i}  IN RANGE  ${num_of_olt}
    \  ${OLT_id}=  get_vcli_device_id  ${test_node_ip}  ${OLT_serialNumber_${i}}
    \  append to list  ${OLT_id_list}  ${OLT_id}

    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \  ${ONT_port}=  get_ont_port_onos  ${test_node_ip}  ${ONT_serialNumber_${i}}
    \  ${ONT_id}=  get_vcli_device_id  ${test_node_ip}  ${ONT_serialNumber_${i}}
    \  append to list  ${ONT_id_list}  ${ONT_id}
    \  append to list  ${ONT_port_list}  ${ONT_port}

    :FOR  ${i}  IN RANGE  ${num_of_subscribers}
    \  Update_subscriber_provision.json  ${i}  @{ONT_port_list}[${i}]  @{ont_number_list}[${i}]

update_ont_provision_w_ontnumber

    @{ONT_id_list}=  create list
    @{ONT_port_list}=  create list
    @{OLT_id_list}=  create list

    set global variable  @{ONT_id_list}  @{ONT_id_list}
    set global variable  @{ONT_port_list}  @{ONT_port_list}
    set global variable  @{OLT_id_list}  @{OLT_id_list}

    :FOR  ${i}  IN RANGE  ${num_of_olt}
    \  ${OLT_id}=  get_vcli_device_id  ${test_node_ip}  ${OLT_serialNumber_${i}}
    \  append to list  ${OLT_id_list}  ${OLT_id}

    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \  ${ONT_id}=  get_vcli_device_id  ${test_node_ip}  ${ONT_serialNumber_${i}}
    \  append to list  ${ONT_id_list}  ${ONT_id}

    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \  Update_ONT_provision.json  ${i}  @{ont_number_list}[${i}]
    #============================
    #Other keywords:
    #============================

Update_variables_in_test_variables
    [Documentation]  updates the variables in test-robot.variables file.
    [Arguments]  ${variable_name}  ${variable_value}  ${new_value}

    ${test_variables}=  OperatingSystem.Get File  test-variables.robot     # convert json to a dictionary variable
    ${test_variables}=  replace string  ${test_variables}  ${variable_name}=${SPACE}${SPACE}${variable_value}  ${variable_name}=${SPACE}${SPACE}${new_value}
    OperatingSystem.Create File  test-variables.robot  content=${test_variables}
    log to console  updated variable in test-variables.robot




