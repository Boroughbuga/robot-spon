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


Setup
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


get_BBSL_Port
    [Documentation]  #get the port of bbsl service from target machine, warns if it isn't the default port:32000
    write  kubectl get svc --all-namespaces | grep "bbsl-service" | awk '{print $6}'
    sleep  6s
    ${bbsl_port}=  read
    ${bbsl_port}=  get lines matching regexp  ${bbsl_port}  9090  partial_math=True
    ${bbsl_port}=  get substring  ${bbsl_port}  5  10
    log to console  \nbbsl port: "${bbsl_port}"
    [Return]  ${bbsl_port}


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


