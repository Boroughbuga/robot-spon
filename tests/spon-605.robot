*** Settings ***
Documentation    Required Libraries

Library  SSHLibrary
Library  String
Library  Collections
Library  OperatingSystem
Library  RequestsLibrary

Resource  common_keywords.robot

Test Setup  Delay4request
Suite Setup  TestStart
Suite Teardown  TestEnd

*** Variables ***
${bbslport}=  32000
${test_machine_name}=  192.168.45.13
#dev machine ips: 192.168.31.200, 192.168.45.13, 192.168.31.180 ...
${username}=  jenkins
#dev machine username= jenkins, argela ...
${test_node_ip}=  192.168.45.21
#nodes: 192.168.31.200, 192.168.45.21/22/23, 192.168.31.180 ...

#OLT info
${OLT_ip}=  192.168.70.31
#ankara= 192.168.70.31 istanbul=192.168.31.252 bbsim= gets from kubectl get svc
${OLT_port}=  9191
#9191, bbsim=50060

#bbsim parameters
${bbsim_running}=  False
#true if bbsim is used
${bbsim_no}=  1

#chassis parameters
${clli}=  1111
${rack}=  1
${shelf}=  1

#OLT parameters
${OLT_clli}=  ${clli}
${OLT_port}=  ${OLT_port}
${OLT_name}=  Test_OLT_1
${oltDriver}=  OPENOLT
${deviceType}=  OPENOLT
${OLT_ipAddress}=  ${OLT_ip}   #updates the ip if bbsim is used

#ONT parameters
${ONT_clli}=   ${clli}
${ONT_slotNumber}=  1
${ONT_ponPortNumber}=  1
${ontNumber}=  1
${ONT_serialNumber}=  ISKT71e81998
#BBSM00000100 (bbsim) ISKT71e81998 ...

#Tech profile

${num_of_tech_profiles}=  2

${tech_profile_name0}=  service/voltha/technology_profiles/xgspon/65
${tech_profile_data0}=  { \"name\": \"2Service\", \"profile_type\": \"XPON\", \"version\": 1.0, \"num_gem_ports\": 1, \"instance_control\": {\"onu\": \"multi-instance\",\"uni\": \"multi-instance\",\"max_gem_payload_size\": \"auto\" }, \"us_scheduler\": {\"additional_bw\": \"auto\",\"direction\": \"UPSTREAM\",\"priority\": 0,\"weight\": 0,\"q_sched_policy\": \"hybrid\" }, \"ds_scheduler\": {\"additional_bw\": \"auto\",\"direction\": \"DOWNSTREAM\",\"priority\": 0,\"weight\": 0,\"q_sched_policy\": \"hybrid\" }, \"upstream_gem_port_attribute_list\": [{\"pbit_map\": \"0b10000000\",\"aes_encryption\": \"True\",\"scheduling_policy\": \"StrictPriority\",\"priority_q\": 2,\"weight\": 0,\"discard_policy\": \"TailDrop\",\"max_q_size\": \"auto\",\"discard_config\": {\"max_threshold\": 0,\"min_threshold\": 0,\"max_probability\": 0} } ], \"downstream_gem_port_attribute_list\": [{\"pbit_map\": \"0b10000000\",\"aes_encryption\": \"True\",\"scheduling_policy\": \"StrictPriority\",\"priority_q\": 2,\"weight\": 0,\"discard_policy\": \"TailDrop\",\"max_q_size\": \"auto\",\"discard_config\": {\"max_threshold\": 0,\"min_threshold\": 0,\"max_probability\": 0} } ]}

${tech_profile_name1}=  service/voltha/technology_profiles/xgspon/64
${tech_profile_data1}=  { \"name\": \"1Service\", \"profile_type\": \"XPON\", \"version\": 1.0, \"num_gem_ports\": 1, \"instance_control\": {\"onu\": \"multi-instance\",\"uni\": \"multi-instance\",\"max_gem_payload_size\": \"auto\" }, \"us_scheduler\": {\"additional_bw\": \"auto\",\"direction\": \"UPSTREAM\",\"priority\": 0,\"weight\": 0,\"q_sched_policy\": \"hybrid\" }, \"ds_scheduler\": {\"additional_bw\": \"auto\",\"direction\": \"DOWNSTREAM\",\"priority\": 0,\"weight\": 0,\"q_sched_policy\": \"hybrid\" }, \"upstream_gem_port_attribute_list\": [{\"pbit_map\": \"0b00000001\",\"aes_encryption\": \"True\",\"scheduling_policy\": \"StrictPriority\",\"priority_q\": 1,\"weight\": 0,\"discard_policy\": \"TailDrop\",\"max_q_size\": \"auto\",\"discard_config\": {\"max_threshold\": 0,\"min_threshold\": 0,\"max_probability\": 0} } ], \"downstream_gem_port_attribute_list\": [{\"pbit_map\": \"0b00000001\",\"aes_encryption\": \"True\",\"scheduling_policy\": \"StrictPriority\",\"priority_q\": 1,\"weight\": 0,\"discard_policy\": \"TailDrop\",\"max_q_size\": \"auto\",\"discard_config\": {\"max_threshold\": 0,\"min_threshold\": 0,\"max_probability\": 0} } ]}

#Speed Profile

${num_of_speed_profiles}=  6

${speed_profile_name0}=  High-Speed-Internet
${speed_profile_data0}=  {\"id\": \"High-Speed-Internet\",\"cir\": 500000,\"cbs\": 10000,\"eir\": 500000,\"ebs\": 10000,\"air\": 100000}

${speed_profile_name1}=  VOIP
${speed_profile_data1}=  {\"id\": \"VOIP\",\"cir\": 4000,\"cbs\": 1000,\"eir\": 4000,\"ebs\": 1000,\"air\": 1000}

${speed_profile_name2}=  Default
${speed_profile_data2}=  {\"id\": \"Default\",\"cir\": 0,\"cbs\": 0,\"eir\": 512,\"ebs\": 30,\"air\": 0}

${speed_profile_name3}=  IPTV
${speed_profile_data3}=  {\"id\": \"IPTV\",\"cir\": 5000,\"cbs\": 3000,\"eir\": 1000,\"ebs\": 3000,\"air\": 1000}

${speed_profile_name4}=  User1-Specific
${speed_profile_data4}=  {\"id\": \"User1-Specific\",\"cir\": 6000,\"cbs\": 1000,\"eir\": 4000,\"ebs\": 1000}

${speed_profile_name5}=  User1-Specific2
${speed_profile_data5}=  {\"id\": \"User1-Specific2\",\"cir\": 5000,\"cbs\": 1000,\"eir\": 3000,\"ebs\": 1000}

#Subscriber
${subscriber_userIdentifier}=  user-81
${subscriber_nasPortId}=  ${ONT_serialNumber}
${subscriber_macAddress}=  00:04:13:74:39:9f
${subscriber_clli}=  ${clli}
${Subscriber_slotNumber}=  ${ONT_slotNumber}
${subscriber_portNumber}=  ${ONT_ponPortNumber}
${subscriber_ontNumber}=  ${ontNumber}
${subscriber_uniPortNumber}=  16
${subscriber_services_name}=  HSIA
${subscriber_services_stag}=  7
${subscriber_services_ctag}=  34
${subscriber_services_usctagPriority}=  7
${subscriber_services_usstagPriority}=  7
${subscriber_services_dsctagPriority}=  7
${subscriber_services_dsstagPriority}=  7
${subscriber_services_defaultVlan}=  35
${subscriber_services_technologyProfileId}=  1
${subscriber_services_upStreamProfileId}=  4
${subscriber_services_downStreamProfileId}=  1
${subscriber_services_useDstMac}=  false

${subscriber_services}=  [{ "name" : "${subscriber_services_name}", "stag" : ${subscriber_services_stag}, "ctag" : ${subscriber_services_ctag}, "usctagPriority" : ${subscriber_services_usctagPriority}, "usstagPriority" : ${subscriber_services_usstagPriority}, "dsctagPriority" : ${subscriber_services_dsctagPriority}, "dsstagPriority" : ${subscriber_services_dsstagPriority}, "defaultVlan" : ${subscriber_services_defaultVlan}, "technologyProfileId" : ${subscriber_services_technologyProfileId}, "upStreamProfileId" : ${subscriber_services_upStreamProfileId}, "downStreamProfileId" : ${subscriber_services_downStreamProfileId}, "useDstMac":"${subscriber_services_useDstMac}" }]

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
    log to console  \n BBSL Chassis add request is sent.

    sleep  4s
    ${response}=  get request  bbsl-api  /inventory/all
    should be equal as strings  ${response.status_code}  200
    ${chassis_status}=  Evaluate  [x for x in ${response.json()} if x['rack'] == '${rack}']
    ${chassis_status}=  Evaluate  [x for x in ${response.json()} if x['shelf'] == '${shelf}']
    ${chassis_status}=  Evaluate  [x for x in ${response.json()} if x['clli'] == '${clli}']
    ${chassis_status}=  get from dictionary  ${chassis_status}[0]  clli
    should be equal as strings  ${clli}  ${chassis_status}
    log to console  \nTest Passed: Chassis with name:${chassis_status} is added to chasssis list.

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
    log to console  \nTest passed: OLT add request is sent

    sleep  4s
    ${response}=  get request  bbsl-api  /inventory/all
    should be equal as strings  ${response.status_code}  200
    ${OLT_status}=  Evaluate  [x for x in ${response.json()} if x['rack'] == '${rack}']
    ${OLT_status}=  Evaluate  [x for x in ${response.json()} if x['shelf'] == '${shelf}']
    ${OLT_status}=  Evaluate  [x for x in ${response.json()} if x['clli'] == '${clli}']
    ${OLT_status}=  get from dictionary  ${OLT_status}[0]  olts
    ${OLT_status}=  Evaluate  [x for x in ${OLT_status} if x['name'] == '${OLT_name}']
    ${OLT_status}=  get from dictionary  ${OLT_status}[0]  name

    should be equal as strings  ${OLT_name}  ${OLT_status}
    log to console  \nTest Passed: OLT with name:${OLT_status} is added to OLT list.

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
    log to console  \nTest passed: ONT provision request is sent

    ${response}=  get request  bbsl-api  /ont/${ONT_serialNumber}
    should be equal as strings  ${response.status_code}  200
    ${ONTserial}=  get from dictionary  ${response.json()}  serialNumber
    should be equal as strings  ${ONT_serialNumber}  ${ONTserial}
    log to console  \nTest passed: ONT provisioned successfully

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

    :FOR  ${i}  IN RANGE  ${num_of_tech_profiles}

    \  #add Technology profile
    \  ${response}=  post request  bbsl-api  /technologyprofile/save  data=${tech_profile_dictionary${i}}  headers=${headers}
    \  should be equal as strings  ${response.status_code}  200
    \  log to console  \nTechnology profile add request sent successfully

    \  sleep  4s
    \  ${response}=  get request  bbsl-api  /technologyprofile/list
    \  should be equal as strings  ${response.status_code}  200
    \  ${techprofile_status}=  Evaluate  [x for x in ${response.json()} if x['name'] == '${tech_profile_name${i}}']
    \  ${techprofile_status}=  get from dictionary  ${techprofile_status}[0]  name
    \  should be equal as strings  ${tech_profile_name${i}}  ${techprofile_status}
    \  log to console  \n Techprofile with name:${techprofile_status} is added to techprofilelist.
    log to console  \nTest Passed: Techprofiles added

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: Add Technology profile failed

test12
    [Tags]    Sprint6  BBSL
    [Documentation]  Add Speed profile

    :FOR  ${i}  IN RANGE  ${num_of_speed_profiles}

    \  #add Speed Profile
    \  ${response}=  post request  bbsl-api  /speedprofile/save  data=${speed_profile_dictionary${i}}  headers=${headers}
    \  should be equal as strings  ${response.status_code}  200
    \  log to console  \nTest passed: Speed profile: ${speed_profile_name${i}} add request sent successfully

    \  sleep  4s
    \  ${response}=  get request  bbsl-api  /speedprofile/list
    \  should be equal as strings  ${response.status_code}  200
    \  ${speedprofile_status}=  Evaluate  [x for x in ${response.json()} if x['name'] == '${speed_profile_name${i}}']
    \  ${speedprofile_status1}=  get from dictionary  ${speedprofile_status}[0]  name
    \  should be equal as strings  ${speed_profile_name${i}}  ${speedprofile_status1}
    \  ${speedprofile_status2}=  get from dictionary  ${speedprofile_status}[0]  data
    \  should be equal as strings  ${speed_profile_data${i}}  ${speedprofile_status2}
    \  log to console  \n Speedprofile with ID:${speedprofile_status1} is added to speedprofilelist.
    log to console  \nTest Passed: Speed profiles added

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: Adding speed profile failed

test13
    [Tags]    Sprint6  BBSL
    [Documentation]  Provision subscriber

    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/subscriber_provision.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    #provision subscriber
    ${response}=  post request  bbsl-api  /subscriber/provision  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: subsriber:${subscriber_userIdentifier} provision request sent successfully

#    sleep  4s
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

    #delete ONT and check if deleted
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_delete.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  delete request  bbsl-api  /ont/delete  data=${jsonfile}  headers=${headers}
    should not be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: ONT delete request returned ${response.status_code}

    sleep  4s
    ${response}=  get request  bbsl-api  /ont/${ONT_serialNumber}
    should be equal as strings  ${response.status_code}  200
    should not be equal as strings  ${response.json()}  {u'slotNumber': 0, u'ontNumber': 0, u'ponPortNumber': 0, u'ponPortId': 0, u'portNumber': 0, u'id': 0}

    log to console  \nONT is not deleted as we expected.

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT deleted

test15
    [Tags]    Sprint6  BBSL
    [Documentation]  Delete Subscriber

    #delete subscriber and check if deleted
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/subscriber_delete.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  delete request  bbsl-api  /subscriber/delete  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: Subscriber delete request sent


    #partially complete
    #

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: Subscriber is failed to be deleted.

test16
    [Tags]    Sprint6  BBSL
    [Documentation]  Delete an ONT that is in Whitelist

    #delete ONT and check if deleted
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_delete.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  delete request  bbsl-api  /ont/delete  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: ONT delete request sent

    sleep  4s
    ${response}=  get request  bbsl-api  /ont/${ONT_serialNumber}
    should be equal as strings  ${response.status_code}  200
    should be equal as strings  ${response.json()}  {u'slotNumber': 0, u'ontNumber': 0, u'ponPortNumber': 0, u'ponPortId': 0, u'portNumber': 0, u'id': 0}

    log to console  \nONT is deleted successfully

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: something went wrong in ONT delete.

test17
    [Tags]    Sprint6  BBSL
    [Documentation]  Delete an ONT that has no subscriber behind it

    #delete ONT and check if deleted
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_delete.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  delete request  bbsl-api  /ont/delete  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: ONT delete request sent

    sleep  4s
    ${response}=  get request  bbsl-api  /ont/${ONT_serialNumber}
    should be equal as strings  ${response.status_code}  200
    should be equal as strings  ${response.json()}  {u'slotNumber': 0, u'ontNumber': 0, u'ponPortNumber': 0, u'ponPortId': 0, u'portNumber': 0, u'id': 0}

    log to console  \nONT is deleted successfully

    #partially complete

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT delete failed

test18
    [Tags]    Sprint6  BBSL
    [Documentation]  Delete an OLT that has no subscriber behind it

    #get OLT information: get OLT name from get inventory list, and then get the unique ID to use in Check OLT request
    ${response}=  get request  bbsl-api  /inventory/all
    should be equal as strings  ${response.status_code}  200
    @{id_get}=  Evaluate  filter(lambda x: x['clli'] == '${OLT_clli}', ${response.json()})
    @{id_get}=  Evaluate  filter(lambda x: x['rack'] == ${rack}, @{id_get})
    @{id_get}=  Evaluate  filter(lambda x: x['shelf'] == ${shelf}, @{id_get})
    ${id_get}=  get from dictionary  @{id_get}[0]  olts
    @{id_get}=  Evaluate  filter(lambda x: x['name'] == '${OLT_name}', ${response.json()[0]["olts"]})
    ${id_get}=  get from dictionary  @{id_get}[0]  deviceId

    Update_OLT_delete.json  ${id_get}

    #add OLT from BBSL
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/OLT_delete.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  delete request  bbsl-api  /olt/delete  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \nTest passed: OLT delete request is sent

    sleep  4s
    ${response}=  get request  bbsl-api  /olt/${id_get}
    should be equal as strings  ${response.status_code}  200
    should be equal as strings  ${response.json()}  {u'port': 0}

    log to console  \nTest Passed: OLT with ID:${id_get} is deleted from OLT list.

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: OLT is not added.

test19
    [Tags]    Sprint6  BBSL
    [Documentation]  Delete Chassis

    #delete chassis
    ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/chassis_delete.json
    &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    ${response}=  delete request  bbsl-api  /chassis/delete  data=${jsonfile}  headers=${headers}
    should be equal as strings  ${response.status_code}  200
    log to console  \n BBSL Chassis delete request is sent.

    sleep  4s
    ${response}=  get request  bbsl-api  /chassis/${clli}
    should be equal as strings  ${response.status_code}  200
    should be equal as strings  ${response.json()}  {}

    log to console  \nTest Passed: Chassis with name:${clli} is deleted from chasssis list.

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: Chassis add Failed

#test20-test
#
#    ${subscriber_delete_dictionary}=  set variable  {"userIdentifier" : "${subscriber_userIdentifier}", "services" : ["HSIA"]}
#    ${json}=  evaluate  json.dumps(${subscriber_delete_dictionary})  json
#    OperatingSystem.Create File  ../json-files/bbsl-jsons/subscriber_delete.json  content=${json}

*** Keywords ***

TestStart

   [Documentation]  Test initalization

    setup  ${test_machine_name}  ${username}   #SSH to the jenkins
    ${bbsl_port}=  get_BBSL_Port    #get BBSL port from kubectlsvc
    sleep  2s
    #print a warning if the ports isnt expected default port of 32000
    run keyword if  ${bbsl_port}!=32000  log to console  \n"""""""""Warning:"""""""""\nbbsl port isn't default port: 32000\n""""""""""""""""""""""""""

    ${OLT_ipAddress}=  run keyword if  "${bbsim_running}" == "True"  get_bbsim_ip  ${bbsim_no}    #get the new bbsim-ip to requests

    create session  bbsl-api  http://${test_node_ip}:${bbsl_port}
    &{headers}=  create dictionary  Content-Type=application/json

    set global variable  ${headers}  &{headers}
    set global variable  ${bbslport}  ${bbslport}

    Update_chassis_add_and_delete.json
    Update_OLT_add.json
    Update_ONT_provision.json
    Update_ONT_disable_and_enable.json

    :FOR  ${i}  IN RANGE  ${num_of_tech_profiles}
    \  Update_Tech_profile_add.json  ${i}
    :FOR  ${i}  IN RANGE  ${num_of_speed_profiles}
    \  Update_Speed_profile_add.json  ${i}

    Update_subscriber_provision.json
    Update_ONT_delete.json
    Update_subscriber_delete.json

    log to console  \nHTTP session started


TestEnd

    [Documentation]  tests ended
    delete all sessions
    log to console  \nHTTP session ended
    End SSH to TestMachine

Update_OLT_add.json

    ${OLT_ipAddress}=  set variable  ${OLT_ip}
    ${jsonfile}=  create dictionary  ipAddress=${OLT_ipAddress}  port=${OLT_port}  name=${OLT_name}  clli=${OLT_clli}  oltDriver=${oltDriver}  deviceType=${deviceType}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/OLT_add.json  content=${json}

Update_chassis_add_and_delete.json

    ${jsonfile}=  create dictionary  clli=${clli}  rack=${rack}  shelf=${shelf}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/chassis_add.json  content=${json}
    OperatingSystem.Create File  ../json-files/bbsl-jsons/chassis_delete.json  content=${json}

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

    [Arguments]  ${Tech_profile_no}

    ${tech_profile_dictionary}=  create dictionary  name=${tech_profile_name${Tech_profile_no}}  data=${tech_profile_data${Tech_profile_no}}
    set global variable  ${tech_profile_dictionary${Tech_profile_no}}  ${tech_profile_dictionary}
    ${json}=  evaluate  json.dumps(${tech_profile_dictionary})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/Tech_profile_add${Tech_profile_no}.json  content=${json}

Update_Speed_profile_add.json

    [Arguments]  ${Speed_profile_no}

    ${speed_profile_dictionary}=  create dictionary  name=${speed_profile_name${Speed_profile_no}}  data=${speed_profile_data${Speed_profile_no}}
    set global variable  ${speed_profile_dictionary${Speed_profile_no}}  ${speed_profile_dictionary}
    ${json}=  evaluate  json.dumps(${speed_profile_dictionary})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/speed_profile_add${Speed_profile_no}.json  content=${json}

Update_subscriber_provision.json

    ${subscriber_provision_dictionary}=  set variable  {"userIdentifier" : "${subscriber_userIdentifier}", "macAddress" : "${subscriber_macAddress}", "nasPortId" : "${subscriber_nasPortId}", "clli" : "${subscriber_clli}", "slotNumber" : ${Subscriber_slotNumber}, "portNumber" : ${subscriber_portNumber}, "ontNumber" : ${subscriber_ontNumber}, "uniPortNumber" : ${subscriber_uniPortNumber}, "services" : ${subscriber_services}}

    #${subscriber_provision_dictionary}=  create dictionary  userIdentifier=${subscriber_userIdentifier}  circuitId=${subscriber_circuitId}  nasPortId=${subscriber_nasPortId}  remoteId=${subscriber_remoteId}  creator=${subscriber_creator}  clli=${subscriber_clli}  slotNumber=${Subscriber_slotNumber}  portNumber=${subscriber_portNumber}  ontNumber=${subscriber_ontNumber}  uniPortNumber=${subscriber_uniPortNumber}  services=${subscriber_services}
    #set global variable  ${subscriber_provision_dictionary}  ${subscriber_provision_dictionary}
    ${json}=  evaluate  json.dumps(${subscriber_provision_dictionary})  json

    #${json}=  remove string  ${json}  \\
    #log to console  ${json}
    OperatingSystem.Create File  ../json-files/bbsl-jsons/subscriber_provision.json  content=${json}

Update_OLT_delete.json
    [Arguments]  ${device_id}

    ${OLT_ipAddress}=  set variable  ${OLT_ip}
    ${jsonfile}=  create dictionary  ipAddress=${OLT_ipAddress}  port=${OLT_port}  name=${OLT_name}  clli=${OLT_clli}  oltDriver=${oltDriver}  deviceType=${deviceType}  deviceId=${device_id}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/OLT_delete.json  content=${json}

Delay4request
    sleep  4s

Update_ONT_delete.json

    ${jsonfile}=  create dictionary  serialNumber=${ONT_serialNumber}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/ONT_delete.json  content=${json}

Update_subscriber_delete.json

    ${subscriber_delete_dictionary}=  set variable  {"userIdentifier" : "${subscriber_userIdentifier}", "services" : ["HSIA"]}
    ${json}=  evaluate  json.dumps(${subscriber_delete_dictionary})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/subscriber_delete.json  content=${json}
