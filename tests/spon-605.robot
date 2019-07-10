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

#bbsim parameters
${bbsim_no}=  1
${bbsim_port}=  50060

#chassis parameters
${clli}=  1111
${rack}=  1
${shelf}=  1

#OLT parameters
${OLT_clli}=  ${clli}
${OLT_port}=  ${bbsim_port}
${OLT_name}=  Test_OLT_1
${oltDriver}=  OPENOLT
${deviceType}=  OPENOLT
${OLT_ipAddress}=  test   #gets its value from BBSL's ip. get_bbsim_ip  ${bbsim_no}. Comment out that part from setup and then give OLT ip for real OLT.

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
    should be equal as strings  ${response.json()}  {u'shelf': ${shelf}, u'clli': u'${clli}', u'rack': ${rack}}
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
    @{id_get}=  Evaluate  filter(lambda x: x['clli'] == '${OLT_clli}', ${response.json()})
    @{id_get}=  Evaluate  filter(lambda x: x['rack'] == ${rack}, @{id_get})
    @{id_get}=  Evaluate  filter(lambda x: x['shelf'] == ${shelf}, @{id_get})
    ${id_get}=  get from dictionary  @{id_get}[0]  olts
    @{id_get}=  Evaluate  filter(lambda x: x['name'] == '${OLT_name}', ${response.json()[0]["olts"]})
    ${id_get}=  get from dictionary  @{id_get}[0]  deviceId

    #Get OLT BBSL request
    ${response}=  get request  bbsl-api  /olt/${id_get}
    should be equal as strings  ${response.status_code}  200
    dictionary should contain value  ${response.json()}  ${id_get}

    ${status}=  get from dictionary  ${response.json()}  operationalState
    #dictionary should contain value  ${response.json()}  ENABLED
    ${status2}=  get from dictionary  ${response.json()}  adminState
    #dictionary should contain value  ${response.json()}  ACTIVE

    log to console  \n---------------------------------------------\nTest passed: OLT retrieve is working properly: \n OLT:${OLT_name} ID:${id_get} is added, ${status}, ${status2} \n---------------------------------------------

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: OLT is not in the list of devices

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
    [Tags]    Sprint6  BBSL
    [Documentation]  Provision subscriber

    #provision subscriber
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/subscriber_provision.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  post request  bbsl-api  /subscriber/provision  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: subscriber provisioned successfully

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: Subscriber provision failed

test15
    [Tags]    Sprint6  BBSL
    [Documentation]  Delete an ONT with a subscriber behind it

    #provision subscriber
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/subscriber_provision.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  post request  bbsl-api  /subscriber/provision  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: subscriber provisioned successfully

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: Subscriber provision failed

testtest
    ${response}=  get request  bbsl-api  /inventory/all
    @{id_get}=  Evaluate  filter(lambda x: x['clli'] == '${OLT_clli}', ${response.json()})
    @{id_get}=  Evaluate  filter(lambda x: x['rack'] == ${rack}, @{id_get})
    @{id_get}=  Evaluate  filter(lambda x: x['shelf'] == ${shelf}, @{id_get})
    ${id_get}=  get from dictionary  @{id_get}[0]  olts
    ${found}=  Evaluate  filter(lambda x: x['name'] == '${OLT_name}', ${response.json()[0]["olts"]})
    dictionary should contain value  ${found}[0]  00019066ce8a935e
    ${found}=  get from dictionary  ${found}[0]  deviceId
    log to console  ======${found}

#    @{id_get}=  Evaluate  [x for x in @{id_get} if x['clli'] == '${clli}']
#    @{id_get}=  Evaluate  [x for x in @{id_get} if x['rack'] == ${rack}]
#    @{id_get}=  Evaluate  [x for x in @{id_get} if x['shelf'] == ${shelf}]
#
#    log to console  asdasd${response.json()[0]["olts"][0]["deviceId"]}



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

    Update_chassis_add.json
    Update_OLT_add.json

    log to console  \nHTTP session started


TestEnd

    [Documentation]  tests ended
    delete all sessions
    log to console  \nHTTP session ended
    End SSH to TestMachine

Update_OLT_add.json

    ${OLT_ipAddress}=  set variable  ${bbsim_ip}
    ${jsonfile}=  create dictionary  ipAddress=${OLT_ipAddress}  port=${OLT_port}  name=${OLT_name}  clli=${OLT_clli}  oltDriver=${oltDriver}  deviceType=${deviceType}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/OLT_add.json  content=${json}


Update_chassis_add.json

    ${jsonfile}=  create dictionary  clli=${clli}  rack=${rack}  shelf=${shelf}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/chassis_add.json  content=${json}

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

Update_subscriber_provision.json



