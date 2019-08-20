*** Settings ***
Library  SSHLibrary
Library  String
Library  Collections
Library  OperatingSystem
Library  Dialogs
Library  RequestsLibrary

Resource  common_keywords.robot
Resource  test-variables.robot

Test Setup
Test Teardown  End SSH to TestMachine

*** Variables ***

*** Keywords ***

For_loop_check_pods

    [Arguments]  ${list_of_pods}  ${current_namespace}  ${num_of_pods_in_ns}  ${pods_in_machine}
    :FOR  ${i}  IN RANGE  ${num_of_pods_in_ns}
    \
    \  ${pods_w_cur_ns}=  get lines matching regexp  ${pods_in_machine}  ${space}${list_of_pods}[${i}]  partial_math=True
    # \  log to console  ${space}${list_of_pods}[${i}]
    \  set test variable  ${curpod}  ${list_of_pods}[${i}]
    \  &{cur_properties}=  get from dictionary  ${current_namespace}  ${list_of_pods}[${i}]     #get a  sub-dictionary within a dictionary
    \  ${cur_status}=  get from dictionary  ${cur_properties}  STATUS              #get key's value from a dictionary
    \  ${cur_ready}=  get from dictionary  ${cur_properties}  READY                #get key's value from a dictionary
    \  ${cur_num_of_reps}=  get from dictionary  ${cur_properties}  num_of_pods   #get key's value from a dictionary
    \
    \  run keyword if  '${cur_num_of_reps}'!='1'  checknumofreps  ${cur_num_of_reps}  ${pods_w_cur_ns}
    \
    \  @{podproperties}=  split string  ${pods_w_cur_ns}
    #\  log to console  \n---@{podproperties}----
    #\  log to console  \n@{podproperties}[2]
    #\  log to console  \n@{podproperties}[3]
    \  should be equal  ${cur_status}  @{podproperties}[3]
    \  should be equal  ${cur_ready}  @{podproperties}[2]
    \  log to console  \n------------------------------------------------\n[podname]:${list_of_pods}[${i}]\n @{podproperties}[2]=${cur_ready} && @{podproperties}[3]=${cur_status}

for_loop_check_services
    [Arguments]  ${num_of_services_in_ns}  ${svc_current_namespace}  ${services_in_machine}
    :FOR  ${i}  IN RANGE  ${num_of_services_in_ns}
    \
    \  ${services_w_cur_ns}=  get lines matching regexp  ${services_in_machine}  ${space}${svc_current_namespace}[${i}]  partial_math=True
    \  set test variable  ${cur_service}  ${svc_current_namespace}[${i}]
    \  @{service_properties}=  split string  ${services_w_cur_ns}
    \  should be equal  ${svc_current_namespace}[${i}]  @{service_properties}[1]
    \  log to console  \n------------------------------------------------\n[service]:${svc_current_namespace}[${i}]==@{service_properties}[1]

checknumofreps   #checks the pods that should have more than 1 instance running at the same time and compares it to the current running pods.
    [Arguments]  ${cur_num_of_reps}  ${pods_w_cur_ns}
    @{lines}=  split to lines  ${pods_w_cur_ns}
    ${length}=  get length  ${lines}
    ${cur_num_of_reps}=  convert to integer  ${cur_num_of_reps}
    should be equal  ${cur_num_of_reps}  ${length}

Setup
    Setup_ssh  ${test_machine_name}  ${username}


*** Test Cases ***

Test1
    [Documentation]  kubectl get nodes çıktısının alınması ve 3 node'un da Ready olduğunun kontrolü

    Setup_ssh  ${test_machine_name}  ${username}
    sleep  2s
#   write  kubectl get nodes | grep node | awk '{print $1}'
    write  kubectl get nodes
    sleep  2s
    ${output}=  read
    ${output}=  get lines containing string  ${output}  node
    log to console  \n${output}

    @{nodelist}=  split to lines  ${output}

    @{node1}=  split string  ${nodelist}[0]
    @{node2}=  split string  ${nodelist}[1]
    @{node3}=  split string  ${nodelist}[2]

    should be equal  @{node1}[0]  node1
    should be equal  @{node1}[1]  Ready
    should be equal  @{node2}[0]  node2
    should be equal  @{node2}[1]  Ready
    should be equal  @{node3}[0]  node3
    should be equal  @{node3}[1]  Ready

    log to console  \n node1, node2, node3 all are up and ready!

Test2   #kubectl get pods --all-namespaces
    [Documentation]     comparing the machines' "kubectl get pods --all-namespaces" output with the one in our pods.json
                    #   for all pods in the json,if the expected pod Status and Container number are achieved, test passes.

    Setup_ssh  ${test_machine_name}  ${username}
    sleep  2s

    ${jsonfile}=  OperatingSystem.Get File  ../json-files/spon-507-jsons/spon-507-pods.json     # convert json to a dictionary variable
    ${pods_dict}=  Evaluate  json.loads('''${jsonfile}''')  json

    ${output}=  get dictionary keys  ${pods_dict}  sort_keys=False      # get the list of keys in the dictionary
    &{namespaces}=  get from dictionary  ${pods_dict}  ${output}[0]     #get a  sub-dictionary within a dictionary

    ${list_of_ns}=  get dictionary keys  ${namespaces}  sort_keys=False         # get the list of keys in the dictionary
    ${num_of_ns}=  get length  ${list_of_ns}

    :FOR  ${i}  IN RANGE  ${num_of_ns}
    \  &{current_namespace}=  get from dictionary  ${namespaces}  ${list_of_ns}[${i}]     #get a  sub-dictionary within a dictionary
    \  log to console  \n==================================================\n checking pods of: "${list_of_ns}[${i}]" namespace\n==================================================
    \  ${list_of_pods}=  get dictionary keys  ${current_namespace}  sort_keys=False      # get the list of keys in the dictionary
    \
    \  write  kubectl get pods --all-namespaces | grep ^${list_of_ns}[${i}]
    \  sleep  2s
    \  ${pods_in_machine}=  read
    \
    \  ${num_of_pods_in_ns}=  get length  ${list_of_pods}
    \  log to console  number of pods in ${list_of_ns}[${i}] namespace: ${num_of_pods_in_ns}\n==================================================
    \  for_loop_check_pods  ${list_of_pods}  ${current_namespace}  ${num_of_pods_in_ns}  ${pods_in_machine}

    [Teardown]  run keyword if test failed  log to console  \n there is a problem with the pod: ${curpod}

Test3   #kubectl get svc --all-namespaces

#   comparing the machines' "kubectl get svc --all-namespaces" output with the one in our services.json
#   for all services in the json; if the expected service exists, test passes.
#=====================
    Setup_ssh  ${test_machine_name}  ${username}
    sleep  2s

    ${jsonfile}=  OperatingSystem.Get File  ../json-files/spon-507-jsons/spon-507-services.json     # convert json to a dictionary variable
    ${services_dict}=  Evaluate  json.loads('''${jsonfile}''')  json

    ${output}=  get dictionary keys  ${services_dict}  sort_keys=False      # get the list of keys in the dictionary
    &{namespaces}=  get from dictionary  ${services_dict}  ${output}[0]     #get a  sub-dictionary within a dictionary

    ${list_of_ns}=  get dictionary keys  ${namespaces}  sort_keys=False         # get the list of keys in the dictionary
    ${num_of_ns}=  get length  ${list_of_ns}

    :FOR  ${i}  IN RANGE  ${num_of_ns}
    \  @{svc_current_namespace}=  get from dictionary  ${namespaces}  ${list_of_ns}[${i}]     #get a  sub-dictionary within a dictionary
    \  log to console  \n==================================================\n checking services in: "${list_of_ns}[${i}]" namespace\n==================================================
    \
    \  write  kubectl get svc --all-namespaces | grep ^${list_of_ns}[${i}]
    \  sleep  2s
    \  ${services_in_machine}=  read
    \
    \  ${num_of_services_in_ns}=  get length  ${svc_current_namespace}
    \  log to console  number of services in ${list_of_ns}[${i}] namespace: ${num_of_services_in_ns}\n==================================================
#    \  ${services_w_cur_ns}=  get lines matching regexp  ${services_in_machine}  ${space}${svc_current_namespace}[0]  partial_math=True
#    \  log to console  ${services_w_cur_ns}
    \  for_loop_check_services  ${num_of_services_in_ns}  ${svc_current_namespace}  ${services_in_machine}

    [Teardown]  run keyword if test failed  log to console  \n there is a problem with the service: ${cur_service}
