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

    :FOR  ${i}  IN RANGE  ${num_of_olt}
    \  #add OLT from BBSL
    \  ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/OLT_add_${i}.json
    \  &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    \  ${response}=  post request  bbsl-api  /olt/add  data=${jsonfile}  headers=${headers}
    \  should be equal as strings  ${response.status_code}  200
    \  dictionary should contain item  ${response.json()}  message  Request failed with validation error

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

    :FOR  ${i}  IN RANGE  ${num_of_olt}
    \  #add OLT from BBSL
    \  ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/OLT_add_${i}.json
    \  &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    \  ${response}=  post request  bbsl-api  /olt/add  data=${jsonfile}  headers=${headers}
    \  should be equal as strings  ${response.status_code}  200
    \  log to console  \nTest passed: OLT add request is sent
    \  dictionary should contain item  ${response.json()}  result  SUCCESS
    \  log to console  \nTest passed: OLT with serial: ${OLT_serialNumber_${i}} is added

    get_ont_number_bbsl
    update_ont_provision_w_ontnumber

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: OLT is not added.

#    sleep  4s
#    ${response}=  get request  bbsl-api  /inventory/all
#    should be equal as strings  ${response.status_code}  200
#    ${OLT_status}=  Evaluate  [x for x in ${response.json()} if x['rack'] == '${rack}']
#    ${OLT_status}=  Evaluate  [x for x in ${response.json()} if x['shelf'] == '${shelf}']
#    ${OLT_status}=  Evaluate  [x for x in ${response.json()} if x['clli'] == '${clli}']
#    ${OLT_status}=  get from dictionary  ${OLT_status}[0]  olts
#    ${OLT_status}=  Evaluate  [x for x in ${OLT_status} if x['name'] == '${OLT_name}']
#    ${OLT_status}=  get from dictionary  ${OLT_status}[0]  name
#    should be equal as strings  ${OLT_name}  ${OLT_status}
#    log to console  \nTest Passed: OLT with name:${OLT_status} is added to OLT list.
test6
    [Tags]    Sprint6  BBSL
    [Documentation]  Check OLT

    get_ont_number_bbsl
    update_ont_provision_w_ontnumber
    #get OLT information: get OLT name from get inventory list, and then get the unique ID to use in Check OLT request
    ${response}=  get request  bbsl-api  /inventory/all
    should be equal as strings  ${response.status_code}  200
    :FOR  ${i}  IN RANGE  ${num_of_olt}
    \  @{id_get}=  Evaluate  filter(lambda x: x['clli'] == '${OLT_clli_${i}}', ${response.json()})
    \  @{id_get}=  Evaluate  filter(lambda x: x['rack'] == ${rack}, @{id_get})
    \  @{id_get}=  Evaluate  filter(lambda x: x['shelf'] == ${shelf}, @{id_get})
    \  ${id_get}=  get from dictionary  @{id_get}[${i}]  olts
    \  @{id_get}=  Evaluate  filter(lambda x: x['name'] == '${OLT_name_${i}}', ${response.json()[0]["olts"]})
    \  ${id_get}=  get from dictionary  @{id_get}[${i}]  deviceId
    \  #Get OLT BBSL request
    \  ${response}=  get request  bbsl-api  /olt/${id_get}
    \  should be equal as strings  ${response.status_code}  200
    \  dictionary should contain value  ${response.json()}  ${id_get}
    \  ${status}=  get from dictionary  ${response.json()}  operationalState
    \  #dictionary should contain value  ${response.json()}  ENABLED
    \  ${status2}=  get from dictionary  ${response.json()}  adminState
    \  #dictionary should contain value  ${response.json()}  ACTIVE
    \  log to console  \n---------------------------------------------\nTest passed: OLT retrieve is working properly: \n OLT:${OLT_name_${i}} ID:${id_get} is added, ${status}, ${status2} \n---------------------------------------------

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: OLT is not in the list of devices

test7
    [Tags]    Sprint6  BBSL
    [Documentation]  Provision ONT
    get_ont_number_bbsl
    update_ont_provision_w_ontnumber
    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \  #provision ONT
    \  ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_provision_${i}.json
    \  &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    \  ${response}=  post request  bbsl-api  /ont/provision  data=${jsonfile}  headers=${headers}
    \  should be equal as strings  ${response.status_code}  200
    \  log to console  \nTest passed: ONT provision request is sent for ONT serial: ${ONT_serialNumber_${i}}
    \  ${response}=  get request  bbsl-api  /ont/${ONT_serialNumber_${i}}
    \  should be equal as strings  ${response.status_code}  200
    \  ${ONTserial}=  get from dictionary  ${response.json()}  serialNumber
    \  should be equal as strings  ${ONT_serialNumber_${i}}  ${ONTserial}
    \  log to console  \nTest passed: ONT with serial:${ONT_serialNumber_${i}} provisioned successfully

    update_subscriber_provision_w_ontnumber&port
    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT provision failed

test8
    [Tags]    Sprint6  BBSL
    [Documentation]  Check ONT

    get_ont_number_bbsl
    update_ont_provision_w_ontnumber
    update_subscriber_provision_w_ontnumber&port
    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \  ${response}=  get request  bbsl-api  /ont/${ONT_serialNumber_${i}}
    \  should be equal as strings  ${response.status_code}  200
    \  ${deviceid}=  get from dictionary  ${response.json()}  deviceId
    \  ${status}=  get from dictionary  ${response.json()}  operationalState
    \  ${status2}=  get from dictionary  ${response.json()}  adminState
    \  log to console  \n---------------------------------------------\nTest passed: ONT check is working properly: \n ONT serial no:${ONT_serialNumber_${i}} ID:${deviceid} is added, ${status}, ${status2} \n---------------------------------------------

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT is not in the list of devices

test9
    [Tags]    Sprint6  BBSL
    [Documentation]  Disable ONT
    get_ont_number_bbsl
    update_ont_provision_w_ontnumber
    update_subscriber_provision_w_ontnumber&port
    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \    #disable ONT and check if disabled
    \  ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_disable_${i}.json
    \  &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    \  ${response}=  post request  bbsl-api  /ont/disable  data=${jsonfile}  headers=${headers}
    \  should be equal as strings  ${response.status_code}  200
    \  log to console  \nTest passed: ONT disable request sent for serial: ${ONT_serialNumber_${i}}
    \  sleep  4s
    \  ${response}=  get request  bbsl-api  /ont/${ONT_serialNumber_${i}}
    \  should be equal as strings  ${response.status_code}  200
    \  ${status}=  get from dictionary  ${response.json()}  adminState
    \  should be equal as strings  DISABLED  ${status}
    \  log to console  \nONT with serial ${ONT_serialNumber_${i}} is ${status}

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT disable failed

test10
    [Tags]    Sprint6  BBSL
    [Documentation]  Enable ONT
    get_ont_number_bbsl
    update_ont_provision_w_ontnumber
    update_subscriber_provision_w_ontnumber&port
    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \    #enable ONT and check if enabled
    \  ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_enable_${i}.json
    \  &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    \  ${response}=  post request  bbsl-api  /ont/enable  data=${jsonfile}  headers=${headers}
    \  should be equal as strings  ${response.status_code}  200
    \  log to console  \nTest passed: ONT enable request for serial: ${ONT_serialNumber_${i}} is sent
    \  sleep  4s
    \  ${response}=  get request  bbsl-api  /ont/${ONT_serialNumber_${i}}
    \  should be equal as strings  ${response.status_code}  200
    \  ${status}=  get from dictionary  ${response.json()}  adminState
    \  should be equal as strings  ENABLED  ${status}
    \  log to console  \nONT with serial:${ONT_serialNumber_${i}}is ${status}

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT enable failed

test11
    [Tags]    Sprint6  BBSL
    [Documentation]  Add Technology profile

    :FOR  ${i}  IN RANGE  ${num_of_tech_profiles}
    \  #add Technology profile
    \  ${response}=  post request  bbsl-api  /technologyprofile/save  data=${tech_profile_dictionary_${i}}  headers=${headers}
    \  should be equal as strings  ${response.status_code}  200
    \  log to console  \nTechnology profile add request sent successfully
    \  dictionary should contain item  ${response.json()}  result  SUCCESS
    \  sleep  4s
    \  ${response}=  get request  bbsl-api  /technologyprofile/list
    \  should be equal as strings  ${response.status_code}  200
    \  ${techprofile_status}=  Evaluate  [x for x in ${response.json()} if x['name'] == '${d_tech_profile_name_${i}}']
    \  ${techprofile_status}=  get from dictionary  ${techprofile_status}[0]  name
    \  should be equal as strings  ${d_tech_profile_name_${i}}  ${techprofile_status}
    \  log to console  \n Techprofile with name:${techprofile_status} is added to techprofilelist.
    log to console  \nTest Passed: Techprofiles added

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: Add Technology profile failed

test12
    [Tags]    Sprint6  BBSL
    [Documentation]  Add Speed profile

    :FOR  ${i}  IN RANGE  ${num_of_speed_profiles}
    \  #add Speed Profile
    \  ${response}=  post request  bbsl-api  /speedprofile/save  data=${speed_profile_dictionary_${i}}  headers=${headers}
    \  should be equal as strings  ${response.status_code}  200
    \  log to console  \nSpeed profile: ${speed_profile_name_${i}} add request sent successfully
    \  dictionary should contain item  ${response.json()}  result  SUCCESS
    \  sleep  4s
    \  ${response}=  get request  bbsl-api  /speedprofile/list
    \  should be equal as strings  ${response.status_code}  200
    \  ${speedprofile_status}=  Evaluate  [x for x in ${response.json()} if x['name'] == '${speed_profile_name_${i}}']
    \  ${speedprofile_status1}=  get from dictionary  ${speedprofile_status}[0]  name
    \  should be equal as strings  ${speed_profile_name_${i}}  ${speedprofile_status1}
    \  ${speedprofile_status2}=  get from dictionary  ${speedprofile_status}[0]  data
    \  should be equal as strings  ${speed_profile_data_${i}}  ${speedprofile_status2}
    \  log to console  \n Speedprofile with ID:${speedprofile_status1} is added to speedprofilelist.

    log to console  \nTest Passed: Speed profiles added

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: Adding speed profile failed

test13
    [Tags]    Sprint6  BBSL
    [Documentation]  Provision subscriber
    get_ont_number_bbsl
    update_ont_provision_w_ontnumber
    update_subscriber_provision_w_ontnumber&port
    :FOR  ${i}  IN RANGE  ${num_of_subscribers}
    \  ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/subscriber_provision_${i}.json
    \  &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    \  #provision subscriber
    \  ${response}=  post request  bbsl-api  /subscriber/provision  data=${jsonfile}  headers=${headers}
    \  should be equal as strings  ${response.status_code}  200
    \  log to console  \nTest passed: subsriber:${subscriber_userIdentifier_${i}} provision request sent successfully
    \  dictionary should contain item  ${response.json()}  result  SUCCESS
    \  log to console  \nTest passed: subsriber:${subscriber_userIdentifier_${i}} provisioned successully
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

    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \  #delete ONT and check if deleted
    \  ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_delete_${i}.json
    \  &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    \  ${response}=  delete request  bbsl-api  /ont/delete  data=${jsonfile}  headers=${headers}
    \  should not be equal as strings  ${response.status_code}  200
    \  log to console  \nTest passed: ONT delete request returned ${response.status_code}
    \  sleep  4s
    \  ${response}=  get request  bbsl-api  /ont/${ONT_serialNumber_${i}}
    \  should be equal as strings  ${response.status_code}  200
    \  should not be equal as strings  ${response.json()}  {u'slotNumber': 0, u'ontNumber': 0, u'ponPortNumber': 0, u'ponPortId': 0, u'portNumber': 0, u'id': 0}
    \  log to console  \nONT with serial:${ONT_serialNumber_${i}}is not deleted as we expected.

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT deleted

test15
    [Tags]    Sprint6  BBSL
    [Documentation]  Delete Subscriber

    :FOR  ${i}  IN RANGE  ${num_of_subscribers}
    \  #delete subscriber and check if deleted
    \  ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/subscriber_delete_${i}.json
    \  &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    \  ${response}=  delete request  bbsl-api  /subscriber/delete  data=${jsonfile}  headers=${headers}
    \  should be equal as strings  ${response.status_code}  200
    \  log to console  \nTest passed: Subscriber delete request sent for subscriber ${subscriber_userIdentifier_${i}}
    # add a way to check if it is deleted?

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: Subscriber is failed to be deleted.

test16
    [Tags]    Sprint6  BBSL
    [Documentation]  Delete an ONT that is in Whitelist

    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \  #delete ONT and check if deleted
    \  ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_delete_${i}.json
    \  &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    \  ${response}=  delete request  bbsl-api  /ont/delete  data=${jsonfile}  headers=${headers}
    \  should be equal as strings  ${response.status_code}  200
    \  log to console  \nTest passed: ONT delete request sent for ont serial: ${ONT_serialNumber_${i}}
    \  sleep  4s
    \  ${response}=  get request  bbsl-api  /ont/${ONT_serialNumber_${i}}
    \  should be equal as strings  ${response.status_code}  200
    \  should be equal as strings  ${response.json()}  {u'slotNumber': 0, u'ontNumber': 0, u'ponPortNumber': 0, u'ponPortId': 0, u'portNumber': 0, u'id': 0}
    \  log to console  \nONT is deleted successfully

    [Teardown]  run keyword if test failed  \nlog to console  Test failed: something went wrong in ONT delete.

test17
    [Tags]    Sprint6  BBSL
    [Documentation]  Delete an ONT that has no subscriber behind it

    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \  #delete ONT and check if deleted
    \  ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/ONT_delete_${i}.json
    \  &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    \  ${response}=  delete request  bbsl-api  /ont/delete  data=${jsonfile}  headers=${headers}
    \  should be equal as strings  ${response.status_code}  200
    \   log to console  \nTest passed: ONT delete request sent for serial:${ONT_serialNumber_${i}}
    \  sleep  4s
    \  ${response}=  get request  bbsl-api  /ont/${ONT_serialNumber_${i}}
    \  should be equal as strings  ${response.status_code}  200
    \  should be equal as strings  ${response.json()}  {u'slotNumber': 0, u'ontNumber': 0, u'ponPortNumber': 0, u'ponPortId': 0, u'portNumber': 0, u'id': 0}
    \  log to console  \nONT is deleted successfully
    # add a way to check if it is deleted?
    [Teardown]  run keyword if test failed  \nlog to console  Test failed: ONT delete failed

test18
    [Tags]    Sprint6  BBSL
    [Documentation]  Delete an OLT that has no subscriber behind it

    :FOR  ${i}  IN RANGE  ${num_of_olt}
    \    #get OLT information: get OLT name from get inventory list, and then get the unique ID to use in Check OLT request
    \  ${response}=  get request  bbsl-api  /inventory/all
    \  should be equal as strings  ${response.status_code}  200
    \  @{id_get}=  Evaluate  filter(lambda x: x['clli'] == '${OLT_clli_${i}}', ${response.json()})
    \  @{id_get}=  Evaluate  filter(lambda x: x['rack'] == ${rack}, @{id_get})
    \  @{id_get}=  Evaluate  filter(lambda x: x['shelf'] == ${shelf}, @{id_get})
    \  ${id_get}=  get from dictionary  @{id_get}[0]  olts
    \  @{id_get}=  Evaluate  filter(lambda x: x['name'] == '${OLT_name_${i}}', ${response.json()[0]["olts"]})
    \  ${id_get}=  get from dictionary  @{id_get}[0]  deviceId
    \  Update_OLT_delete.json  ${id_get}  ${i}
    \  #delete OLT from BBSL
    \  ${json}=  OperatingSystem.Get File  ../json-files/bbsl-jsons/OLT_delete_${i}.json
    \  &{jsonfile}=  Evaluate  json.loads('''${json}''')  json
    \  ${response}=  delete request  bbsl-api  /olt/delete  data=${jsonfile}  headers=${headers}
    \  should be equal as strings  ${response.status_code}  200
    \  log to console  \nTest passed: OLT delete request is sent
    \  sleep  4s
    \  ${response}=  get request  bbsl-api  /olt/${id_get}
    \  should be equal as strings  ${response.status_code}  200
    \  should be equal as strings  ${response.json()}  {u'port': 0}
    \  log to console  \nTest Passed: OLT with ID:${id_get} is deleted from OLT list.

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

*** Keywords ***

TestStart

   [Documentation]  Test initalization


    setup_ssh  ${test_machine_name}  ${username}   #SSH to the jenkins

    ${bbsl_running}=  check_bbsl_status
    create_session_bbsl_w_status  ${bbsl_running}  ${test_node_ip}

    ${bbsim_running}=  check_bbsim_status  ${bbsim_no}
    ${bbsim_ip}=  get_bbsim_ip_w_status  ${bbsim_running}  ${bbsim_no}
    ${OLT_ip_0}=  run keyword if  "${bbsim_ip}" != "None"  set variable  ${bbsim_ip}

    #update/create BBSL jsons
    Update_chassis_add_and_delete.json
    :FOR  ${i}  IN RANGE  ${num_of_olt}
    \  Update_OLT_add.json  ${i}
    :FOR  ${i}  IN RANGE  ${num_of_ont}
    \  Update_ONT_disable.json  ${i}
    \  Update_ONT_enable.json  ${i}
    \  Update_ONT_delete.json  ${i}
    :FOR  ${i}  IN RANGE  ${num_of_tech_profiles}
    \  Update_Tech_profile_add.json  ${i}
    :FOR  ${i}  IN RANGE  ${num_of_speed_profiles}
    \  Update_Speed_profile_add.json  ${i}
    :FOR  ${i}  IN RANGE  ${num_of_subscribers}
    \  Update_subscriber_delete.json  ${i}

TestEnd

    [Documentation]  tests ended
    delete all sessions
    log to console  \nHTTP session ended
    End SSH to TestMachine

Delay4request
    sleep  4s








