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
${ONT_clli}=   ${clli}
${ONT_slotNumber}=  1
${ONT_ponPortNumber}=  1
${ontNumber}=  1
${ONT_serialNumber}=  BBSM00000100

#Tech profile
${tech_profile_name}=  service/voltha/technology_profiles/xgspon/67
${tech_profile_data}=  "{ \"name\": \"1Service\", \"profile_type\": \"XPON\", \"version\": 1.0, \"num_gem_ports\": 1, \"instance_control\": {\"onu\": \"multi-instance\",\"uni\": \"multi-instance\",\"max_gem_payload_size\": \"auto\" }, \"us_scheduler\": {\"additional_bw\": \"auto\",\"direction\": \"UPSTREAM\",\"priority\": 0,\"weight\": 0,\"q_sched_policy\": \"hybrid\" }, \"ds_scheduler\": {\"additional_bw\": \"auto\",\"direction\": \"DOWNSTREAM\",\"priority\": 0,\"weight\": 0,\"q_sched_policy\": \"hybrid\" }, \"upstream_gem_port_attribute_list\": [{\"pbit_map\": \"0b00000100\",\"aes_encryption\": \"True\",\"scheduling_policy\": \"WRR\",\"priority_q\": 2,\"weight\": 25,\"discard_policy\": \"TailDrop\",\"max_q_size\": \"auto\",\"discard_config\": {\"max_threshold\": 0,\"min_threshold\": 0,\"max_probability\": 0} } ], \"downstream_gem_port_attribute_list\": [{\"pbit_map\": \"0b00001000\",\"aes_encryption\": \"True\",\"scheduling_policy\": \"WRR\",\"priority_q\": 3,\"weight\": 10,\"discard_policy\": \"TailDrop\",\"max_q_size\": \"auto\",\"discard_config\": {\"max_threshold\": 0,\"min_threshold\": 0,\"max_probability\": 0} } ]}

#Speed Profile
${speed_profile_name}=  High-Speed-Internet
${speed_profile_data}=  {\"id\": \"High-Speed-Internet\",\"cir\": 500000,\"cbs\": 10000,\"eir\": 500000,\"ebs\": 10000,\"air\": 100000}
# Choose the speed profile from below and modify
#    "name" : “IPTV",
#    "data" : "{\"id\": \"IPTV\",\"cir\": 500000000,\"cbs\": 348000,\"eir\": 10000000,\"ebs\": 348000,\"air\": 10000000}"
#    "name" : "High-Speed-Internet",
#    "data" : "{\"id\": \"High-Speed-Internet\",\"cir\": 500000,\"cbs\": 10000,\"eir\": 500000,\"ebs\": 10000,\"air\": 100000}"
#    "name" : "User1-Specific",
#    "data" : "{\"id\": \"User1-Specific\",\"cir\": 600000,\"cbs\": 10000,\"eir\": 400000,\"ebs\": 10000}"
#    "name" : "User1-Specific2",
#    "data" : "{\"id\": \"User1-Specific2\",\"cir\": 500000,\"cbs\": 10000,\"eir\": 300000,\"ebs\": 10000}"
#    "name" : "Default",
#    "data" : "{\"id\": \"Default\",\"cir\": 0,\"cbs\": 0,\"eir\": 512,\"ebs\": 30,\"air\": 0}"

#Subscriber
${subscriber_userIdentifier}=  user-81
${subscriber_circuitId}=  1
${subscriber_nasPortId}=  ${ONT_serialNumber}
${subscriber_remoteId}=  ${EMPTY}
${subscriber_creator}=  ${EMPTY}
${subscriber_clli}=  ${clli}
${Subscriber_slotNumber}=  ${ONT_slotNumber}
${subscriber_portNumber}=  ${ONT_ponPortNumber}
${subscriber_ontNumber}=  ${ontNumber}
${subscriber_uniPortNumber}=  2064
${subscriber_services}=  [{ "id" : 1, "name" : "HSI", "stag" : 7, "ctag" : 34, "stagPriority" : 3, "ctagPriority" : 3, "defaultVlan" : 35, "technologyProfileId" : 5, "upStreamProfileId" : 8, "downStreamProfileId" : 6 }]
#&{subscriber_services}=  id=1  name=HSI  stag=7  ctag=34  stagPriority=3  ctagPriority=3  defaultVlan=35  technologyProfileId=5  upStreamProfileId=8  downStreamProfileId=6

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
    should be equal as strings  ${response.status_code}  200
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
    [Documentation]  Provision ONT

    #provision ONT
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_provision.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  post request  bbsl-api  /ont/provision  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: ONT provisioned successfully

    ${response}=  get request  bbsl-api  /ont/${ONT_serialNumber}
    should be equal as strings  ${response.status_code}  200
    ${ONTserial}=  get from dictionary  ${response.json()}  serialNumber
    should be equal as strings  ${ONT_serialNumber}  ${ONTserial}

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT provision failed

test8
    [Tags]    Sprint6  BBSL
    [Documentation]  Check ONT

    ${response}=  get request  bbsl-api  /ont/${ONT_serialNumber}
    should be equal as strings  ${response.status_code}  200
    ${deviceid}=  get from dictionary  ${response.json()}  deviceId
    ${status}=  get from dictionary  ${response.json()}  operationalState
    ${status2}=  get from dictionary  ${response.json()}  adminState

    log to console  \n---------------------------------------------\nTest passed: ONT check is working properly: \n ONT serial no:${ONT_serialNumber} ID:${deviceid} is added, ${status}, ${status2} \n---------------------------------------------

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT is not in the list of devices

test9
    [Tags]    Sprint6  BBSL
    [Documentation]  Disable ONT

    #disable ONT and check if disabled
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_disable.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  post request  bbsl-api  /ont/disable  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: ONT disable request sent

    sleep  4s
    ${response}=  get request  bbsl-api  /ont/${ONT_serialNumber}
    should be equal as strings  ${response.status_code}  200
    ${status}=  get from dictionary  ${response.json()}  adminState
    should be equal as strings  DISABLED  ${status}
    log to console  \nONT is ${status}

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT disable failed

test10
    [Tags]    Sprint6  BBSL
    [Documentation]  Enable ONT

    #enable ONT and check if enabled
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_enable.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  post request  bbsl-api  /ont/enable  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: ONT enable request sent

    sleep  4s
    ${response}=  get request  bbsl-api  /ont/${ONT_serialNumber}
    should be equal as strings  ${response.status_code}  200
    ${status}=  get from dictionary  ${response.json()}  adminState
    should be equal as strings  ENABLED  ${status}
    log to console  \nONT is ${status}

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT enable failed

test11
    [Tags]    Sprint6  BBSL
    [Documentation]  Add Technology profile

    #add Technology profile
    ${response}=  post request  bbsl-api  /technologyprofile/save  data=${tech_profile_dictionary}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTechnology profile add request sent successfully

    sleep  4s
    ${response}=  get request  bbsl-api  /technologyprofile/list
    should be equal as strings  ${response.status_code}  200
    ${techprofile_status}=  Evaluate  [x for x in ${response.json()} if x['name'] == '${tech_profile_name}']
    ${techprofile_status}=  get from dictionary  ${techprofile_status}[0]  name
    should be equal as strings  ${tech_profile_name}  ${techprofile_status}
    log to console  \nTest Passed: Techprofile with name:${techprofile_status} is added to techprofilelist.

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: Add Technology profile failed

test12
    [Tags]    Sprint6  BBSL
    [Documentation]  Add Speed profile

    #add Speed Profile
    ${response}=  post request  bbsl-api  /speedprofile/save  data=${speed_profile_dictionary}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: Speed profile: ${speed_profile_name} add request sent successfully

    sleep  4s
    ${response}=  get request  bbsl-api  /speedprofile/list
    should be equal as strings  ${response.status_code}  200
    ${speedprofile_status}=  Evaluate  [x for x in ${response.json()} if x['name'] == '${speed_profile_name}']
    ${speedprofile_status1}=  get from dictionary  ${speedprofile_status}[0]  name
    should be equal as strings  ${speed_profile_name}  ${speedprofile_status1}
    ${speedprofile_status2}=  get from dictionary  ${speedprofile_status}[0]  data
    should be equal as strings  ${speed_profile_data}  ${speedprofile_status2}
    log to console  \nTest Passed: Speedprofile with ID:${speedprofile_status1} is added to speedprofilelist.

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: Adding speed profile failed

test13
    [Tags]    Sprint6  BBSL
    [Documentation]  Provision subscriber

    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/subscriber_provision.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json

    #provision subscriber
    ${response}=  post request  bbsl-api  /subscriber/provision  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: Speed profile: subsriber:${subscriber_userIdentifier} provision request sent successfully

    sleep  4s
#    ${response}=  get request  bbsl-api  /technologyprofile/list
#    should be equal as strings  ${response.status_code}  200
#    ${techprofile_status}=  Evaluate  [x for x in ${response.json()} if x['name'] == '${tech_profile_name}']
#    ${techprofile_status}=  get from dictionary  ${techprofile_status}[0]  name
#    should be equal as strings  ${tech_profile_name}  ${techprofile_status}
#    log to console  \nTest Passed: Techprofile with name:${techprofile_status} is added to techprofilelist.

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: Subscriber provision failed

test14
    [Tags]    Sprint6  BBSL
    [Documentation]  Delete an ONT with a subscriber behind it

#code here...

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: Subscriber provision failed

testtest
    log to console  asdasdad
*** Keywords ***

TestStart

   [Documentation]  Test initalization

    setup  ${test_machine_name}  ${username}   #SSH to the jenkins
    ${bbsl_port}=  get_BBSL_Port    #get BBSL port from kubectlsvc
    sleep  2s
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
    Update_ONT_provision.json
    Update_ONT_disable_and_enable.json
    Update_Tech_profile_add.json
    Update_Speed_profile_add.json
    Update_subscriber_provision.json

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

Update_ONT_provision.json

    ${jsonfile}=  create dictionary  serialNumber=${ONT_serialNumber}  clli=${ONT_clli}  slotNumber=${ONT_slotNumber}  ponPortNumber=${ONT_ponPortNumber}  ontNumber=${ontNumber}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/ONT_provision.json  content=${json}

Update_ONT_disable_and_enable.json

    ${jsonfile}=  create dictionary  serialNumber=${ONT_serialNumber}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/ONT_disable.json  content=${json}
    OperatingSystem.Create File  ../json-files/bbsl-jsons/ONT_enable.json  content=${json}

Update_Tech_profile_add.json

    ${tech_profile_dictionary}=  create dictionary  name=${tech_profile_name}  data=${tech_profile_data}
    set global variable  ${tech_profile_dictionary}  ${tech_profile_dictionary}
    ${json}=  evaluate  json.dumps(${tech_profile_dictionary})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/Tech_profile_add.json  content=${json}

Update_Speed_profile_add.json

    ${speed_profile_dictionary}=  create dictionary  name=${speed_profile_name}  data=${speed_profile_data}
    set global variable  ${speed_profile_dictionary}  ${speed_profile_dictionary}
    ${json}=  evaluate  json.dumps(${speed_profile_dictionary})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/speed_profile_add.json  content=${json}

Update_subscriber_provision.json

    ${subscriber_provision_dictionary}=  set variable  {"userIdentifier" : "${subscriber_userIdentifier}", "circuitId" : "${subscriber_circuitId}", "nasPortId" : "${subscriber_nasPortId}", "remoteId" : "${subscriber_remoteId}", "creator" : "${subscriber_creator}", "clli" : "${subscriber_clli}", "slotNumber" : ${Subscriber_slotNumber}, "portNumber" : ${subscriber_portNumber}, "ontNumber" : ${subscriber_ontNumber}, "uniPortNumber" : ${subscriber_uniPortNumber}, "services" : ${subscriber_services}}
    log to console  ${subscriber_provision_dictionary}

    #${subscriber_provision_dictionary}=  create dictionary  userIdentifier=${subscriber_userIdentifier}  circuitId=${subscriber_circuitId}  nasPortId=${subscriber_nasPortId}  remoteId=${subscriber_remoteId}  creator=${subscriber_creator}  clli=${subscriber_clli}  slotNumber=${Subscriber_slotNumber}  portNumber=${subscriber_portNumber}  ontNumber=${subscriber_ontNumber}  uniPortNumber=${subscriber_uniPortNumber}  services=${subscriber_services}
    #set global variable  ${subscriber_provision_dictionary}  ${subscriber_provision_dictionary}
    ${json}=  evaluate  json.dumps(${subscriber_provision_dictionary})  json

    #${json}=  remove string  ${json}  \\
    #log to console  ${json}
    OperatingSystem.Create File  ../json-files/bbsl-jsons/subscriber_provision.json  content=${json}




