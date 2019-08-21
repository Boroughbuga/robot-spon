*** Settings ***

Library  SSHLibrary
Library  String
Library  Collections
Library  OperatingSystem
Library  RequestsLibrary

*** Variables ***
    #============================
    #test environment information:
    #============================

${test_machine_name}=  192.168.45.13
    #dev machine ips: 192.168.31.200, 192.168.45.13, 192.168.31.180 ....
${username}=  jenkins
    #dev machine username= jenkins, argela ...
${test_node_ip}=  192.168.45.21
    #nodes: 192.168.31.200, 192.168.45.21/22/23, 192.168.31.180 ...

    #============================
    #BBSIM informations:
    #============================

${bbsim_running}=  False
#gets true if bbsim is used
${bbsim_no}=  1
#bbsim profile used from premade profiles

    #============================
    #CHASIS informations:
    #============================

${clli}=  Aydinlikevler-1
${rack}=  1
${shelf}=  1

    #============================
    #OLT informations:
    #============================

#OLT ips: ankara= 192.168.70.31, istanbul=192.168.31.252, bbsim= gets from kubectl get svc
#OLT ports: Real OLT=9191, bbsim=50060
#OLT serials: Ankara=EC1840000192, BBSIM1=BBSIMOLT000

#how many OLTs are used?
${num_of_olt}=  1

#OLT-1 info:
${OLT_ip}=  192.168.70.31
${OLT_ipAddress}=  ${OLT_ip}   #updates the ip if bbsim is used
${OLT_port}=  9191
${OLT_clli}=  ${clli}
${OLT_port}=  ${OLT_port}
${OLT_name}=  Edgecore-XGS-PON-1
${oltDriver}=  OPENOLT
${deviceType}=  OPENOLT
${OLT_serialNumber}=  EC1840000192
${OLT_uplink_port_vcli}=  65536
${OLT_downlin_port_vcli}=  1

#OLT-2 info:
${OLT_ip_2}=  192.168.70.31
${OLT_ipAddress_2}=  ${OLT_ip_2}   #updates the ip if bbsim is used
${OLT_port_2}=  9191
${OLT_clli_2}=  ${clli}
${OLT_port_2}=  ${OLT_port}
${OLT_name_2}=  Edgecore-XGS-PON-1
${oltDriver_2}=  OPENOLT
${deviceType_2}=  OPENOLT
${OLT_serialNumber_2}=  EC1840000192
${OLT_uplink_port_vcli_2}=  65536
${OLT_downlin_port_vcli_2}=  1

    #============================
    #ONT informations:
    #============================

#BBSIM ONT serial=BBSM00000100, Ankara ONT-1= ISKT71e81998, Ankara ONT-2

#how many ONTs used?
${num_of_ont}=  2

#ONT-1 info:
${ONT_serialNumber_0}=  ISKT71e819b8
${ONT_mac_0}=  00:02:61:dc:4f:3d
${ONT_clli_0}=   ${clli}
${ONT_uplink_port_vcli_0}=  100
${ONT_slotNumber_0}=  1
${ONT_ponPortNumber_0}=  1
${ontNumber_0}=  1    #get from somewhere
${ont_port_no_0}=  16
#ONT-2 info:
${ONT_serialNumber_1}=  ISKT71e81998
${ONT_mac_1}=  00:02:61:82:30:e5
${ONT_clli_1}=   ${clli}
${ONT_uplink_port_vcli_1}=  100
${ONT_slotNumber_1}=  1
${ONT_ponPortNumber_1}=  1
${ontNumber_1}=  1    #get from somwhwere
${ont_port_no_1}=  16

    #============================
    #TechProfile informations:
    #============================

#how many tech profiles?
${num_of_tech_profiles}=  2

#tech Profile 1:
${tech_profile_name_0}=  1Service
${tech_profile_profile_type_0}=  XPON
${tech_profile_version_0}=  1.0
${tech_profile_no_of_gem_ports_0}=  1
${tech_profile_instance_control_onu_0}=  multi-instance
${tech_profile_instance_control_uni_0}=  multi-instance
${tech_profile_max_gem_payload_size_0}=  auto
${tech_profile_us_additional_bw_0}=  AdditionalBW_BestEffort
${tech_profile_us_direction_0}=  UPSTREAM
${tech_profile_us_priority_0}=  0
${tech_profile_us_weight_0}=  0
${tech_profile_us_q_sched_policy_0}=  hybrid
${tech_profile_ds_additional_bw_0}=  AdditionalBW_BestEffort
${tech_profile_ds_direction_0}=  DOWNSTREAM
${tech_profile_ds_priority_0}=  0
${tech_profile_ds_weight_0}=  0
${tech_profile_ds_q_sched_policy_0}=  hybrid
${tech_profile_upstream_pbit_0}=  0b01000000
${tech_profile_upstream_encryption_0}=  True
${tech_profile_upstream_policy_0}=  StrictPriority
${tech_profile_upstream_p_quene_0}=  3
${tech_profile_upstream_weight_0}=  25
${tech_profile_upstream_discard_0}=  TailDrop
${tech_profile_upstream_max_q_0}=  auto
${tech_profile_upstream_discard_max_0}=  0
${tech_profile_upstream_discard_min_0}=  0
${tech_profile_upstream_discard_probability_0}=  0
${tech_profile_downstream_pbit_0}=  0b11111111
${tech_profile_downstream_encryption_0}=  True
${tech_profile_downstream_policy_0}=  StrictPriority
${tech_profile_downstream_p_quene_0}=  3
${tech_profile_downstream_weight_0}=  25
${tech_profile_downstream_discard_0}=  TailDrop
${tech_profile_downstream_max_q_0}=  auto
${tech_profile_downstream_discard_max_0}=  0
${tech_profile_downstream_discard_min_0}=  0
${tech_profile_downstream_discard_probability_0}=  0

${tech_profile_name0}=
...  service/voltha/technology_profiles/XGS-PON/65
${tech_profile_data0}=
...  { \"name\": \"${tech_profile_name_0}\", \"profile_type\": \"${tech_profile_profile_type_0}\",
...  \"version\": ${tech_profile_version_0}, \"num_gem_ports\": ${tech_profile_no_of_gem_ports_0}, \"instance_control\":
...  {\"onu\": \"${tech_profile_instance_control_onu_0}\",\"uni\": \"${tech_profile_instance_control_uni_0}\",
...  \"max_gem_payload_size\": \"${tech_profile_max_gem_payload_size_0}\" },
...  \"us_scheduler\": {\"additional_bw\": \"${tech_profile_us_additional_bw_0}\",
...  \"direction\": \"${tech_profile_us_direction_0}\",
...  \"priority\": ${tech_profile_us_priority_0},\"weight\": ${tech_profile_us_weight_0},\"q_sched_policy\": \"${tech_profile_us_q_sched_policy_0}\" },
...  \"ds_scheduler\": {\"additional_bw\": \"${tech_profile_ds_additional_bw_0}\",\"direction\": \"${tech_profile_ds_direction_0}\",
...  \"priority\": ${tech_profile_ds_priority_0}, \"weight\": ${tech_profile_ds_weight_0},\"q_sched_policy\": \"${tech_profile_ds_q_sched_policy_0}\" },
...  \"upstream_gem_port_attribute_list\":[{\"pbit_map\": \"${tech_profile_upstream_pbit_0}\",\"aes_encryption\": \"${tech_profile_upstream_encryption_0}\",
...  \"scheduling_policy\": \"${tech_profile_upstream_policy_0}\",\"priority_q\": ${tech_profile_upstream_p_quene_0},
...  \"weight\": ${tech_profile_upstream_weight_0},\"discard_policy\": \"${tech_profile_upstream_discard_0}\",\"max_q_size\": \"${tech_profile_upstream_max_q_0}\",
...  \"discard_config\": {\"max_threshold\": ${tech_profile_upstream_discard_max_0},\"min_threshold\": ${tech_profile_upstream_discard_min_0},
...  \"max_probability\": ${tech_profile_upstream_discard_probability_0}} } ], \"downstream_gem_port_attribute_list\":
...  [{\"pbit_map\": \"${tech_profile_downstream_pbit_0}\",\"aes_encryption\": \"${tech_profile_downstream_encryption_0}\",
...  \"scheduling_policy\": \"${tech_profile_downstream_policy_0}\", \"priority_q\": ${tech_profile_downstream_p_quene_0},
...  \"weight\": ${tech_profile_downstream_weight_0},\"discard_policy\": \"${tech_profile_downstream_discard_0}\",
...  \"max_q_size\": \"${tech_profile_downstream_max_q_0}\",\"discard_config\":
...  {\"max_threshold\": ${tech_profile_downstream_discard_max_0},\"min_threshold\": ${tech_profile_downstream_discard_min_0},
...  \"max_probability\": ${tech_profile_downstream_discard_probability_0}} } ]}

#tech Profile 2:
${tech_profile_name_1}=  2Service
${tech_profile_profile_type_1}=  XPON
${tech_profile_version_1}=  1.0
${tech_profile_no_of_gem_ports_1}=  1
${tech_profile_instance_control_onu_1}=  multi-instance
${tech_profile_instance_control_uni_1}=  multi-instance
${tech_profile_max_gem_payload_size_1}=  auto
${tech_profile_us_additional_bw_1}=  auto
${tech_profile_us_direction_1}=  UPSTREAM
${tech_profile_us_priority_1}=  0
${tech_profile_us_weight_1}=  0
${tech_profile_us_q_sched_policy_1}=  hybrid
${tech_profile_ds_additional_bw_1}=  auto
${tech_profile_ds_direction_1}=  DOWNSTREAM
${tech_profile_ds_priority_1}=  0
${tech_profile_ds_weight_1}=  0
${tech_profile_ds_q_sched_policy_1}=  hybrid
${tech_profile_upstream_pbit_1}=  0b10000000
${tech_profile_upstream_encryption_1}=  True
${tech_profile_upstream_policy_1}=  WRR
${tech_profile_upstream_p_quene_1}=  2
${tech_profile_upstream_weight_1}=  30
${tech_profile_upstream_discard_1}=  TailDrop
${tech_profile_upstream_max_q_1}=  auto
${tech_profile_upstream_discard_max_1}=  0
${tech_profile_upstream_discard_min_1}=  0
${tech_profile_upstream_discard_probability_1}=  0
${tech_profile_downstream_pbit_1}=  0b11111111
${tech_profile_downstream_encryption_1}=  True
${tech_profile_downstream_policy_1}=  WRR
${tech_profile_downstream_p_quene_1}=  2
${tech_profile_downstream_weight_1}=  30
${tech_profile_downstream_discard_1}=  TailDrop
${tech_profile_downstream_max_q_1}=  auto
${tech_profile_downstream_discard_max_1}=  0
${tech_profile_downstream_discard_min_1}=  0
${tech_profile_downstream_discard_probability_1}=  0

${tech_profile_name1}=
...  service/voltha/technology_profiles/XGS-PON/64
${tech_profile_data1}=
...  { \"name\": \"${tech_profile_name_1}\", \"profile_type\": \"${tech_profile_profile_type_1}\",
...  \"version\": ${tech_profile_version_1}, \"num_gem_ports\": ${tech_profile_no_of_gem_ports_1}, \"instance_control\":
...  {\"onu\": \"${tech_profile_instance_control_onu_1}\",\"uni\": \"${tech_profile_instance_control_uni_1}\",
...  \"max_gem_payload_size\": \"${tech_profile_max_gem_payload_size_1}\" },
...  \"us_scheduler\": {\"additional_bw\": \"${tech_profile_us_additional_bw_1}\",
...  \"direction\": \"${tech_profile_us_direction_1}\",
...  \"priority\": ${tech_profile_us_priority_1},\"weight\": ${tech_profile_us_weight_1},\"q_sched_policy\": \"${tech_profile_us_q_sched_policy_1}\" },
...  \"ds_scheduler\": {\"additional_bw\": \"${tech_profile_ds_additional_bw_1}\",\"direction\": \"${tech_profile_ds_direction_1}\",
...  \"priority\": ${tech_profile_ds_priority_1}, \"weight\": ${tech_profile_ds_weight_1},\"q_sched_policy\": \"${tech_profile_ds_q_sched_policy_1}\" },
...  \"upstream_gem_port_attribute_list\":[{\"pbit_map\": \"${tech_profile_upstream_pbit_1}\",\"aes_encryption\": \"${tech_profile_upstream_encryption_1}\",
...  \"scheduling_policy\": \"${tech_profile_upstream_policy_1}\",\"priority_q\": ${tech_profile_upstream_p_quene_1},
...  \"weight\": ${tech_profile_upstream_weight_1},\"discard_policy\": \"${tech_profile_upstream_discard_1}\",\"max_q_size\": \"${tech_profile_upstream_max_q_1}\",
...  \"discard_config\": {\"max_threshold\": ${tech_profile_upstream_discard_max_1},\"min_threshold\": ${tech_profile_upstream_discard_min_1},
...  \"max_probability\": ${tech_profile_upstream_discard_probability_1}} } ], \"downstream_gem_port_attribute_list\":
...  [{\"pbit_map\": \"${tech_profile_downstream_pbit_1}\",\"aes_encryption\": \"${tech_profile_downstream_encryption_1}\",
...  \"scheduling_policy\": \"${tech_profile_downstream_policy_1}\", \"priority_q\": ${tech_profile_downstream_p_quene_1},
...  \"weight\": ${tech_profile_downstream_weight_1},\"discard_policy\": \"${tech_profile_downstream_discard_1}\",
...  \"max_q_size\": \"${tech_profile_downstream_max_q_1}\",\"discard_config\":
...  {\"max_threshold\": ${tech_profile_downstream_discard_max_1},\"min_threshold\": ${tech_profile_downstream_discard_min_1},
...  \"max_probability\": ${tech_profile_downstream_discard_probability_1}} } ]}

#${tech_profile_name1}=  service/voltha/technology_profiles/XGS-PON/65
#${tech_profile_data1}=  { \"name\": \"1Service\", \"profile_type\": \"XPON\", \"version\": 1.0, \"num_gem_ports\": 1, \"instance_control\": {\"onu\": \"multi-instance\",\"uni\": \"multi-instance\",\"max_gem_payload_size\": \"auto\" }, \"us_scheduler\": {\"additional_bw\": \"AdditionalBW_BestEffort\",\"direction\": \"UPSTREAM\",\"priority\": 0,\"weight\": 0,\"q_sched_policy\": \"hybrid\" }, \"ds_scheduler\": {\"additional_bw\": \"AdditionalBW_BestEffort\",\"direction\": \"DOWNSTREAM\",\"priority\": 0,\"weight\": 0,\"q_sched_policy\": \"hybrid\" }, \"upstream_gem_port_attribute_list\": [{\"pbit_map\": \"0b10000000\",\"aes_encryption\": \"True\", \"scheduling_policy\": \"WRR\",\"priority_q\": 2,\"weight\": 30,\"discard_policy\": \"TailDrop\",\"max_q_size\": \"auto\", \"discard_config\": {\"max_threshold\": 0,\"min_threshold\": 0,\"max_probability\": 0} } ], \"downstream_gem_port_attribute_list\": [{\"pbit_map\": \"0b11111111\",\"aes_encryption\": \"True\",\"scheduling_policy\": \"WRR\",\"priority_q\": 2,\"weight\": 30,\"discard_policy\": \"TailDrop\",\"max_q_size\": \"auto\",\"discard_config\": {\"max_threshold\": 0,\"min_threshold\": 0,\"max_probability\": 0} } ]}

    #============================
    #Speedprofile informations:
    #============================

#How many Speed Profiles?
${num_of_speed_profiles}=  6

#Speed Profile 1:
${speed_profile_name0}=  High-Speed-Internet
${speed_profile_data0}=  {\"id\": \"High-Speed-Internet\",\"cir\": 50000,\"cbs\": 32768,\"eir\": 50000,\"ebs\": 32768,\"air\": 1000}
#Speed Profile 2:
${speed_profile_name1}=  VOIP
${speed_profile_data1}=  {\"id\": \"VOIP\",\"cir\": 25000,\"cbs\": 32768,\"eir\": 25000,\"ebs\": 32768,\"air\": 1000}
#Speed Profile 3:
${speed_profile_name2}=  Default
${speed_profile_data2}=  {\"id\": \"Default\",\"cir\": 0,\"cbs\": 0,\"eir\": 512,\"ebs\": 30,\"air\": 0}
#Speed Profile 4:
${speed_profile_name3}=  IPTV
${speed_profile_data3}=  {\"id\": \"IPTV\",\"cir\": 5000,\"cbs\": 32768,\"eir\": 1000,\"ebs\": 32768,\"air\": 1000}
#Speed Profile 5:
${speed_profile_name4}=  User1-Specific
${speed_profile_data4}=  {\"id\": \"User1-Specific\",\"cir\": 25000,\"cbs\": 32768,\"eir\": 25000,\"ebs\": 32768}
#Speed Profile 6:
${speed_profile_name5}=  User1-Specific2
${speed_profile_data5}=  {\"id\": \"User1-Specific2\",\"cir\": 25000,\"cbs\": 32768,\"eir\": 25000,\"ebs\": 32768}

    #============================
    #Subscriber informations:
    #============================

#How many subscriber?
${num_of_subscribers}=  2

#Subscriber - 1:
${subscriber_macAddress_0}=  ${ONT_mac_0}
${subscriber_clli_0}=  ${ONT_clli_0}
${subscriber_nasPortId_0}=  ${ONT_serialNumber_0}
${subscriber_userIdentifier_0}=  user-1
${subscriber_uniPortNumber_0}=  ${ont_port_no_0}
${subscriber_portNumber_0}=  ${ONT_ponPortNumber_0}
${subscriber_ontNumber_0}=  ${ontNumber_0}
${Subscriber_slotNumber_0}=  ${ONT_slotNumber_0}
#hsi
${subscriber_services_name_0}=  HSIA
${subscriber_services_stag_0}=  10
${subscriber_services_ctag_0}=  101
${subscriber_services_usctagPriority_0}=  6
${subscriber_services_usstagPriority_0}=  6
${subscriber_services_dsctagPriority_0}=  -1
${subscriber_services_dsstagPriority_0}=  -1
${subscriber_services_defaultVlan_0}=  35
${subscriber_services_technologyProfileId_0}=  1
${subscriber_services_upStreamProfileId_0}=  1
${subscriber_services_downStreamProfileId_0}=  1
${subscriber_services_useDstMac_0}=  false
#voip
${subscriber_services_name_voip_0}=  VOIP
${subscriber_services_stag_voip_0}=  1546
${subscriber_services_ctag_voip_0}=  46
${subscriber_services_usctagPriority_voip_0}=  7
${subscriber_services_usstagPriority_voip_0}=  7
${subscriber_services_dsctagPriority_voip_0}=  -1
${subscriber_services_dsstagPriority_voip_0}=  -1
${subscriber_services_defaultVlan_voip_0}=  46
${subscriber_services_technologyProfileId_voip_0}=  2
${subscriber_services_upStreamProfileId_voip_0}=  2
${subscriber_services_downStreamProfileId_voip_0}=  2
${subscriber_services_useDstMac_0}=  true

${subscriber_services_0}=
...  {"macAddress": "${subscriber_macAddress_0}","clli": "${subscriber_clli_0}","nasPortId": "${subscriber_nasPortId_0}",
...  "userIdentifier": "${subscriber_userIdentifier_0}","uniPortNumber": ${subscriber_uniPortNumber_0},"portNumber": ${subscriber_portNumber_0},
...  "ontNumber": ${subscriber_ontNumber_0},"slotNumber": ${Subscriber_slotNumber_0},"services": [{"name": "${subscriber_services_name_0}",
...  "stag": ${subscriber_services_stag_0},"ctag": ${subscriber_services_ctag_0},"usctagPriority": ${subscriber_services_usctagPriority_0},
...  "usstagPriority": ${subscriber_services_usstagPriority_0},"dsctagPriority": ${subscriber_services_dsctagPriority_0},"dsstagPriority": ${subscriber_services_dsstagPriority_0},
...  "defaultVlan": ${subscriber_services_defaultVlan_0},"technologyProfileId": ${subscriber_services_technologyProfileId_0},"upStreamProfileId": ${subscriber_services_upStreamProfileId_0},
...  "downStreamProfileId": ${subscriber_services_downStreamProfileId_0},"useDstMac": "${subscriber_services_useDstMac_0}"},{
...  "name": "${subscriber_services_name_voip_0}","stag": ${subscriber_services_stag_voip_0},"ctag": ${subscriber_services_ctag_voip_0},
...  "usctagPriority": ${subscriber_services_usctagPriority_voip_0},"usstagPriority": ${subscriber_services_usstagPriority_voip_0},"dsctagPriority": ${subscriber_services_dsctagPriority_voip_0},
...  "dsstagPriority": ${subscriber_services_dsstagPriority_voip_0},"defaultVlan": ${subscriber_services_defaultVlan_voip_0},"technologyProfileId": ${subscriber_services_technologyProfileId_voip_0},
...  "upStreamProfileId": ${subscriber_services_upStreamProfileId_voip_0},"downStreamProfileId": ${subscriber_services_downStreamProfileId_voip_0},
...  "useDstMac": "${subscriber_services_useDstMac_0}"}]}

#Subscriber - 2:
${subscriber_macAddress_1}=  ${ONT_mac_1}
${subscriber_clli_1}=  ${ONT_clli_1}
${subscriber_nasPortId_1}=  ${ONT_serialNumber_1}
${subscriber_userIdentifier_1}=  user-2
${subscriber_uniPortNumber_1}=  ${ont_port_no_1}
${subscriber_portNumber_1}=  ${ONT_ponPortNumber_1}
${subscriber_ontNumber_1}=  ${ontNumber_1}
${Subscriber_slotNumber_1}=  ${ONT_slotNumber_1}
#hsi
${subscriber_services_name_1}=  HSIA
${subscriber_services_stag_1}=  10
${subscriber_services_ctag_1}=  102
${subscriber_services_usctagPriority_1}=  6
${subscriber_services_usstagPriority_1}=  6
${subscriber_services_dsctagPriority_1}=  -1
${subscriber_services_dsstagPriority_1}=  -1
${subscriber_services_defaultVlan_1}=  35
${subscriber_services_technologyProfileId_1}=  1
${subscriber_services_upStreamProfileId_1}=  1
${subscriber_services_downStreamProfileId_1}=  1
${subscriber_services_useDstMac_1}=  false
#voip
${subscriber_services_name_voip_1}=  VOIP
${subscriber_services_stag_voip_1}=  1546
${subscriber_services_ctag_voip_1}=  46
${subscriber_services_usctagPriority_voip_1}=  7
${subscriber_services_usstagPriority_voip_1}=  7
${subscriber_services_dsctagPriority_voip_1}=  -1
${subscriber_services_dsstagPriority_voip_1}=  -1
${subscriber_services_defaultVlan_voip_1}=  46
${subscriber_services_technologyProfileId_voip_1}=  2
${subscriber_services_upStreamProfileId_voip_1}=  2
${subscriber_services_downStreamProfileId_voip_1}=  2
${subscriber_services_useDstMac_1}=  true

${subscriber_services_1}=
...  {"macAddress": "${subscriber_macAddress_1}","clli": "${subscriber_clli_1}","nasPortId": "${subscriber_nasPortId_1}",
...  "userIdentifier": "${subscriber_userIdentifier_1}","uniPortNumber": ${subscriber_uniPortNumber_1},"portNumber": ${subscriber_portNumber_1},
...  "ontNumber": ${subscriber_ontNumber_1},"slotNumber": ${Subscriber_slotNumber_1},"services": [{"name": "${subscriber_services_name_1}",
...  "stag": ${subscriber_services_stag_1},"ctag": ${subscriber_services_ctag_1},"usctagPriority": ${subscriber_services_usctagPriority_1},
...  "usstagPriority": ${subscriber_services_usstagPriority_1},"dsctagPriority": ${subscriber_services_dsctagPriority_1},"dsstagPriority": ${subscriber_services_dsstagPriority_1},
...  "defaultVlan": ${subscriber_services_defaultVlan_1},"technologyProfileId": ${subscriber_services_technologyProfileId_1},"upStreamProfileId": ${subscriber_services_upStreamProfileId_1},
...  "downStreamProfileId": ${subscriber_services_downStreamProfileId_1},"useDstMac": "${subscriber_services_useDstMac_1}"},{
...  "name": "${subscriber_services_name_voip_1}","stag": ${subscriber_services_stag_voip_1},"ctag": ${subscriber_services_ctag_voip_1},
...  "usctagPriority": ${subscriber_services_usctagPriority_voip_1},"usstagPriority": ${subscriber_services_usstagPriority_voip_1},"dsctagPriority": ${subscriber_services_dsctagPriority_voip_1},
...  "dsstagPriority": ${subscriber_services_dsstagPriority_voip_1},"defaultVlan": ${subscriber_services_defaultVlan_voip_1},"technologyProfileId": ${subscriber_services_technologyProfileId_voip_1},
...  "upStreamProfileId": ${subscriber_services_upStreamProfileId_voip_1},"downStreamProfileId": ${subscriber_services_downStreamProfileId_voip_1},
...  "useDstMac": "${subscriber_services_useDstMac_1}"}]}

    #============================
    #BBSL informations:
    #============================
#${bbsl_port}=  32000  #default bbsl port

*** Test Cases ***
test1
    log to console  \n${tech_profile_data0}
    log to console  ======================
    log to console  \n${subscriber_services_0}