*** Settings ***

Library  SSHLibrary
Library  String
Library  Collections
Library  OperatingSystem
Library  RequestsLibrary

*** Keywords ***
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
    ${jsonfile}=  OperatingSystem.Get File  ../json-files/spon-605-jsons/spon-605-authentication.json     # convert json to a dictionary variable
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
    ${bbsl_port}=  get_BBSL_Port
    run keyword if  "${bbsl_running}" == "True"
#    ...  ${bbsl_port}=  get_BBSL_Port
    ...  create_session_bbsl  ${test_node_ip}  ${bbsl_port}
    ...  ELSE  log to console  BBSL not running, aborted HTTP creation


check_bbsim_status
    [Documentation]  #returns true if there is a bbsim pod running
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
    [Documentation]  #get the IP of BBSL from kubectl get svc
    [Arguments]  ${bbsim_no}
    write  kubectl get svc --all-namespaces | grep "bbsim${bbsim_no}" | awk '{print $4}'
    sleep  2s
    ${bbsim_ip}=  read
    sleep  2s
    ${bbsim_ip}=  get lines matching regexp  ${bbsim_ip}  10.  partial_math=True

    log to console  \nbbsim${bbsim_no} ip: "${bbsim_ip}"
    [Return]  ${bbsim_ip}


get_bbsim_ip_w_status
    [Documentation]  #get the IP of BBSL from kubectl get svc
    [Arguments]  ${bbsim_running}  ${bbsim_no}

    write  kubectl get svc --all-namespaces | grep "bbsim${bbsim_no}" | awk '{print $4}'
    sleep  2s
    ${output}=  read
    sleep  2s
    ${bbsim_ip}=  run keyword if  "${bbsim_running}" == "True"  get lines matching regexp  ${output}  10.  partial_math=True

    log to console  \nbbsim${bbsim_no} ip: "${bbsim_ip}"

    [Return]  ${bbsim_ip}


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


Update_variables_in_test_variables
    [Documentation]  updates the variables in test-robot.variables file.
    [Arguments]  ${variable_name}  ${variable_value}  ${new_value}

    ${test_variables}=  OperatingSystem.Get File  test-variables.robot     # convert json to a dictionary variable
    ${test_variables}=  replace string  ${test_variables}  ${variable_name}=${SPACE}${SPACE}${variable_value}  ${variable_name}=${SPACE}${SPACE}${new_value}
    OperatingSystem.Create File  test-variables.robot  content=${test_variables}
    log to console  updated variable in test-variables.robot


Get_vcli_device_id
    [Documentation]  gets the device id from serial number
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