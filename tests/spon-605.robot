*** Settings ***
Documentation    Required Libraries

Library  SSHLibrary
Library  String
Library  Collections
Library  OperatingSystem
Library  RequestsLibrary

Resource  common_keywords.robot

Suite Setup  TestStart
Suite Teardown  TestEnd

*** Variables ***
${bbslport}=  32000
${test_machine_name}=  192.168.31.200
${username}=  argela

#chassis parameters
${clli}=  1

#bbsim parameters
${bbsim_no}=  1

#OLT parameters
${numberOfPorts}=  1
${port}=  50060
${OLT_name}=  olt.voltha.svc.test
${oltDriver}=  OPENOLT
${deviceType}=  OPENOLT

#ONT parameters
${serialNumber}=  BBSM00000100
${uniPortId}=   100
${deviceId}=   0001cc42081a7cca
${slot}=  1
${ponPortId}=  1
${ontNumber}=  1
${uniPortId}=  2064

#Tech profile
${tech_profile_name}=  service/voltha/technology_profiles/xgspon/66
${tech_profile_data}=  { "name": "1Service", "profile_type": "XPON", "version": 1.0, "num_gem_ports": 1, "instance_control": {"onu": "multi-instance","uni": "multi-instance","max_gem_payload_size": "auto" }, "us_scheduler": {"additional_bw": "auto","direction": "UPSTREAM","priority": 0,"weight": 0,"q_sched_policy": "hybrid" }, "ds_scheduler": {"additional_bw": "auto","direction": "DOWNSTREAM","priority": 0,"weight": 0,"q_sched_policy": "hybrid" }, "upstream_gem_port_attribute_list": [{"pbit_map": "0b00000100","aes_encryption": "True","scheduling_policy": "WRR","priority_q": 2,"weight": 25,"discard_policy": "TailDrop","max_q_size": "auto","discard_config": {"max_threshold": 0,"min_threshold": 0,"max_probability": 0} } ], "downstream_gem_port_attribute_list": [{"pbit_map": "0b00001000","aes_encryption": "True","scheduling_policy": "WRR","priority_q": 3,"weight": 10,"discard_policy": "TailDrop","max_q_size": "auto","discard_config": {"max_threshold": 0,"min_threshold": 0,"max_probability": 0} } ]}

#Speed Profile

#choose one name: IPTV  High-Speed-Internet  User1-Specific  Default
#choose data:
#{\"id\": \"High-Speed-Internet\",\"cir\": 500000,\"cbs\": 10000,\"eir\": 500000,\"ebs\": 10000,\"air\": 100000}
#{\"id\": \"User1-Specific\",\"cir\": 600000,\"cbs\": 10000,\"eir\": 400000,\"ebs\": 10000}
#{\"id\": \"Default\",\"cir\": 0,\"cbs\": 0,\"eir\": 512,\"ebs\": 30,\"air\": 0}
${speed_profile_name}=  High-Speed-Internet
${speed_profile_data}=  {\"id\": \"High-Speed-Internet\",\"cir\": 500000,\"cbs\": 10000,\"eir\": 500000,\"ebs\": 10000,\"air\": 100000}


*** Test Cases ***

Test1
    [Tags]    Sprint6  BBSL
    [Documentation]  check if chasis list is empty or not before adding any chassis. Passes if it is empty as expected.

    #get chassis topology
    ${response}=  get request  bbsl-api  /chassis/${clli}
    should be equal as strings  ${response.status_code}  200
    should be equal as strings  ${response.json()}  {}
    log to console  \nTest passed: chasis list is empty

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: chasis list is not empty

Test2
    [Tags]    Sprint6  BBSL
    [Documentation]  add OLT without chassis, passes if no new OLT is added.

    #add OLT from BBSL
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/OLT_add.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  post request  bbsl-api  /olt/add  data=${jsonfile}  headers=${headers}
    should not be equal as strings  ${response.status_code}  200

    log to console  \nTest passed: no OLT is added without adding chassis

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: OLT is added eventhough no chasis is added.

test3
    [Tags]    Sprint6  BBSL
    [Documentation]  add chassis

    #add chassis
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/chassis_add.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  post request  bbsl-api  /chassis/add  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    sleep  2s
    log to console  \nchassis added

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: Chassis add Failed

test4
    [Tags]    Sprint6  BBSL
    [Documentation]  get chasis

    #get chassis topology
    ${response}=  get request  bbsl-api  /chassis/${clli}
    should be equal as strings  ${response.status_code}  200
    should be equal as strings  ${response.json()}  {u'shelf': 2, u'clli': u'${clli}', u'rack': 1}
    log to console  \nTest passed: chasis with clli: ${clli} added successfully

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: chasis with clli:${clli} is not added

test5
    [Tags]    Sprint6  BBSL
    [Documentation]  add OLT

    #add OLT from BBSL
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/OLT_add.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  post request  bbsl-api  /olt/add  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: OLT added successfully

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: OLT is not added.

test6
    [Tags]    Sprint6  BBSL
    [Documentation]  Check OLT

    #get OLT information: get OLT name from get inventory list, and then get the unique ID to use in Check OLT request
    ${response}=  get request  bbsl-api  /inventory/all
    @{id_get}=  set variable  ${response.json()}
    @{id_get}=  get from dictionary  @{id_get}[0]  olts
    ${found}=  Evaluate  filter(lambda x: x['name'] == '${OLT_name}', ${id_get})
    ${id_get}=  get from dictionary  ${found}[0]  deviceId

    #Get OLT BBSL request
    ${response}=  get request  bbsl-api  /olt/${id_get}
    should be equal as strings  ${response.status_code}  200
    should be equal as strings  ${response.json()}  {u'clli': u'1', u'name': u'olt.voltha.svc.test', u'oltDriver': u'OPENOLT', u'number': 1, u'adminState': u'ENABLED', u'deviceType': u'OPENOLT', u'deviceId': u'${id_get}', u'machineId': u'10.97.29.105:50060', u'operationalState': u'ACTIVATING', u'ipAddress': u'10.97.29.105', u'port': 50060}
    log to console  \n---------------------------------------------\nTest passed: OLT retrieve is working properly: \n${response.json()}\n---------------------------------------------

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: OLT info couldn't be retrieved

test7
    [Tags]    Sprint6  BBSL
    [Documentation]  Add ONT to whitelist

    #add OLT from BBSL
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/whitelist_add.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  post request  bbsl-api  /whitelist/add  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: ONT added to whitelist successfully

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT is failed to be add to whitelist

test8
    [Tags]    Sprint6  BBSL
    [Documentation]  Provision ONT

    #add OLT from BBSL
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_provision.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  post request  bbsl-api  /ont/provision  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: ONT provisioned successfully

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT provision failed

test9
    [Tags]    Sprint6  BBSL
    [Documentation]  Disable ONT

    #add OLT from BBSL
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_disable.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  post request  bbsl-api  /ont/disable  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: ONT disabled successfully

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT disable failed

test10
    [Tags]    Sprint6  BBSL
    [Documentation]  Enable ONT

    #add OLT from BBSL
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_enable.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  post request  bbsl-api  /ont/enable  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: ONT enabled successfully

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT enable failed

test11
    [Tags]    Sprint6  BBSL
    [Documentation]  check ONT

    #check ONT from serial number
    ${response}=  get request  bbsl-api  /ont/${serialNumber}
    should be equal as strings  ${response.status_code}  200
    should be equal as strings  ${response.json()}  {u'serialNumber': u'BBSM00000100', u'clli': u'1', u'slotNumber': 1, u'ontNumber': 1, u'ponPortNumber': 536870913, u'adminState': u'ENABLED', u'portNumber': 1, u'deviceId': u'000129842ea31db5', u'ponPortId': 1, u'operationalState': u'ACTIVE', u'id': 1}
    log to console  \nTest passed: ONT with serial number:${serialNumber} is in ONT list

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT check for ONT serial number: ${serialNumber

test12
    [Tags]    Sprint6  BBSL
    [Documentation]  Add Technology profile

    #add Technology profile

    ${jsonfile}=  create dictionary  name=${tech_profile_name}  data=${tech_profile_data}

    ${response}=  post request  bbsl-api  /technologyprofile/save  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: Technology profile added

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: Add Technology profile faile12

test13
    [Tags]    Sprint6  BBSL
    [Documentation]  Add Speed profile

    #add Speed Profile

    ${jsonfile}=  create dictionary  name=${speed_profile_name}  data=${speed_profile_data}

    ${response}=  post request  bbsl-api  /speedprofile/save  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: Speed profile: ${speed_profile_name} added successfully

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: Adding speed profile failed

test14


*** Keywords ***

TestStart

   [Documentation]  Test initalization
    setup  ${test_machine_name}  ${username}   #SSH to the jenkins
    ${bbsl_port}=  get_BBSL_Port    #get BBSL port from kubectlsvc

    #print a warning if the ports isnt expected default port of 32000
    run keyword if  ${bbsl_port}!=32000  log to console  \n"""""""""Warning:"""""""""\nbbsl port isn't default port: 32000\n""""""""""""""""""""""""""

    ${bbsim_ip}=  get_bbsim_ip  ${bbsim_no}    #get the new bbsim-ip to requests

    create session  bbsl-api  http://${test_machine_name}:${bbsl_port}
    &{headers}=  create dictionary  Content-Type=application/json

    set global variable  ${headers}  &{headers}
    set global variable  ${bbsim_ip}  ${bbsim_ip}
    set global variable  ${bbslport}  ${bbslport}

    Update_OLT_add.json
    Update_whitelist_add.json
    Update_Tech_profile_add.json
    Update_ONT_provision.json
    Update_ONT_enable.json
    Update_ONT_disable.json

    log to console  \nHTTP session started


TestEnd

    [Documentation]  tests ended
    delete all sessions
    log to console  \nHTTP session ended
    End SSH to TestMachine

Update_OLT_add.json

    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/OLT_add.json   #update .json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json

    set to dictionary  ${jsonfile}  ipAddress=${bbsim_ip}
    set to dictionary  ${jsonfile}  numberOfPorts=${numberOfPorts}
    set to dictionary  ${jsonfile}  port=${port}
    set to dictionary  ${jsonfile}  name=${OLT_name}
    set to dictionary  ${jsonfile}  clli=${clli}
    set to dictionary  ${jsonfile}  oltDriver=${oltDriver}
    set to dictionary  ${jsonfile}  deviceType=${deviceType}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/OLT_add.json  content=${json}

Update_whitelist_add.json

    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/whitelist_add.json   #update .json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json

    set to dictionary  ${jsonfile}  serialNumber=${serialNumber}
    set to dictionary  ${jsonfile}  uniPortId=${serialNumber}
    set to dictionary  ${jsonfile}  deviceId=${deviceId}
    set to dictionary  ${jsonfile}  clli=${clli}
    set to dictionary  ${jsonfile}  slot=${slot}
    set to dictionary  ${jsonfile}  ponPortId=${ponPortId}
    set to dictionary  ${jsonfile}  ontNumber=${ontNumber}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/whitelist_add.json  content=${json}

Update_Tech_profile_add.json

    ${jsonfile}=  create dictionary  name=${tech_profile_name}  data=${tech_profile_data}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/Tech_profile_add.json  content=${json}

Update_speed_profile_add.json

    ${jsonfile}=  create dictionary  name=${speed_profile_name}  data=${speed_profile_data}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/speed_profile_add.json  content=${json}

Update_ONT_provision.json

    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_provision.json   #update .json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json

    set to dictionary  ${jsonfile}  serialNumber=${serialNumber}
    set to dictionary  ${jsonfile}  clli=${clli}
    set to dictionary  ${jsonfile}  slotNumber=${slot}
    set to dictionary  ${jsonfile}  ponPortNumber=${ponPortId}
    set to dictionary  ${jsonfile}  ontNumber=${ontNumber}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/ONT_provision.json  content=${json}

Update_ONT_disable.json

    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_provision.json   #update .json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json

    set to dictionary  ${jsonfile}  serialNumber=${serialNumber}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/ONT_provision.json  content=${json}

Update_ONT_enable.json

    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_enable.json   #update .json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json

    set to dictionary  ${jsonfile}  serialNumber=${serialNumber}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/ONT_enable.json  content=${json}




