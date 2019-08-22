*** Settings ***
Documentation    Required Libraries

Library  SSHLibrary
Library  String
Library  Collections
Library  OperatingSystem
Library  RequestsLibrary

Resource  common_keywords.robot
Resource  test-variables.robot

Test Setup  Delay4request
Suite Setup  TestStart
Suite Teardown  TestEnd

*** Variables ***

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
    should be equal as strings  ${response.status_code}  200
    dictionary should contain item  ${response.json()}  description  No chassis exist with given clli
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
    #{'shelf': ${shelf}, 'clli': '${clli}', 'rack': ${rack}}
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
    \  log to console  \nSpeed profile: ${speed_profile_name${i}} add request sent successfully

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

    [Teardown]  run keyword if test failed  log to console  \nTest failed: Subscriber provision failed

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

    setup_ssh  ${test_machine_name}  ${username}   #SSH to the jenkins

    ${bbsl_running}=  check_bbsl_status
    create_session_bbsl_w_status  ${bbsl_running}  ${test_node_ip}
    ${bbsim_running}=  check_bbsim_status  ${bbsim_no}
    ${bbsim_ip}=  get_bbsim_ip_w_status  ${bbsim_running}  ${bbsim_no}
    ${OLT_ip_0}=  run keyword unless  "${bbsim_ip}" == ""  get_bbsim_ip  ${bbsim_no}    #get the new bbsim-ip to requests


    log to console  \n ========\n${bbsl_port}\n${bbsim_ip}\n========

    Update_chassis_add_and_delete.json
    json_loop  Update_OLT_add.json  ${num_of_olt}
    json_loop  Update_ONT_provision.json  ${num_of_ont}
    json_loop  Update_ONT_disable.json  ${num_of_ont}
    json_loop  Update_ONT_enable.json  ${num_of_ont}
    json_loop  Update_Tech_profile_add.json  ${num_of_tech_profiles}
    json_loop  Update_Speed_profile_add.json  ${num_of_speed_profiles}
    json_loop  Update_subscriber_provision.json  ${num_of_subscribers}
    json_loop  Update_ONT_delete.json  ${num_of_ont}
    json_loop  Update_subscriber_delete.json  ${num_of_subscribers}

TestEnd

    [Documentation]  tests ended
    delete all sessions
    log to console  \nHTTP session ended
    End SSH to TestMachine

json_loop
    [Arguments]  ${loop_no}  ${json_name}
    :FOR  ${i}  IN RANGE  ${loop_no}
    \  ${json_name}  ${i}

Update_OLT_add.json
    [Arguments]  ${olt_no}
    ${jsonfile}=  create dictionary  ipAddress=${OLT_ip_${olt_no}}  port=${OLT_port_${olt_no}}  name=${OLT_name_${olt_no}}  clli=${OLT_clli_${olt_no}}  oltDriver=${oltDriver_${olt_no}}  deviceType=${deviceType_${olt_no}}
    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/OLT_add_${olt_no}.json  content=${json}

Update_chassis_add_and_delete.json

    ${jsonfile}=  create dictionary  clli=${clli}  rack=${rack}  shelf=${shelf}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/chassis_add.json  content=${json}
    OperatingSystem.Create File  ../json-files/bbsl-jsons/chassis_delete.json  content=${json}

Update_ONT_provision.json
    [Arguments]  ${ont_no}
    ${jsonfile}=  create dictionary  serialNumber=${ONT_serialNumber_${ont_no}}  clli=${ONT_clli_${ont_no}}  slotNumber=${ONT_slotNumber_${ont_no}}  ponPortNumber=${ONT_ponPortNumber_${ont_no}}  ontNumber=${ontNumber_${ont_no}}
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

    ${tech_profile_dictionary}=  create dictionary  name=${tech_profile_name_${Tech_profile_no}}  data=${tech_profile_data_${Tech_profile_no}}
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
    [Arguments]  ${subscriber_no}
    ${subscriber_provision_dictionary}=  set variable  {"userIdentifier" : "${subscriber_userIdentifier_${subscriber_no}}", "macAddress" : "${subscriber_macAddress_${subscriber_no}}", "nasPortId" : "${subscriber_nasPortId_${subscriber_no}}", "clli" : "${subscriber_clli_${subscriber_no}}", "slotNumber" : ${Subscriber_slotNumber_${subscriber_no}}, "portNumber" : ${subscriber_portNumber_${subscriber_no}}, "ontNumber" : ${subscriber_ontNumber_${subscriber_no}}, "uniPortNumber" : ${subscriber_uniPortNumber_${subscriber_no}}, "services" : ${subscriber_services_${subscriber_no}}}
    #${subscriber_provision_dictionary}=  create dictionary  userIdentifier=${subscriber_userIdentifier}  circuitId=${subscriber_circuitId}  nasPortId=${subscriber_nasPortId}  remoteId=${subscriber_remoteId}  creator=${subscriber_creator}  clli=${subscriber_clli}  slotNumber=${Subscriber_slotNumber}  portNumber=${subscriber_portNumber}  ontNumber=${subscriber_ontNumber}  uniPortNumber=${subscriber_uniPortNumber}  services=${subscriber_services}
    #set global variable  ${subscriber_provision_dictionary}  ${subscriber_provision_dictionary}
    ${json}=  evaluate  json.dumps(${subscriber_provision_dictionary})  json
    #${json}=  remove string  ${json}  \\
    #log to console  ${json}
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

Delay4request
    sleep  4s

#to be updated:
Update_OLT_delete.json
    [Arguments]  ${device_id}

    ${jsonfile}=  create dictionary  ipAddress=${OLT_ipAddress}  port=${OLT_port}  name=${OLT_name}  clli=${OLT_clli}  oltDriver=${oltDriver}  deviceType=${deviceType}  deviceId=${device_id}

    ${json}=  evaluate  json.dumps(${jsonfile})  json
    OperatingSystem.Create File  ../json-files/bbsl-jsons/OLT_delete.json  content=${json}






