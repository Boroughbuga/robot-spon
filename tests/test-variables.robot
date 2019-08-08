*** Settings ***

Library  SSHLibrary
Library  String
Library  Collections
Library  OperatingSystem
Library  RequestsLibrary

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
${OLT_serialNumber}=  EC1840000192
${OLT_uplink_port_vcli}=  65536
${OLT_downlin_port_vcli}=  1

${OLT_serialNumber_0}=  BBSIMOLT000     #test variable
${OLT_serialNumber_1}=  BBSIMOLT000     #test variable

#ONT parameters
${ONT_clli}=   ${clli}
${ONT_slotNumber}=  1
${ONT_ponPortNumber}=  1
${ontNumber}=  1
${ONT_serialNumber}=  ISKT71e819b8
${ONT_uplink_port_vcli}=  100

${ONT_serialNumber_0}=  BBSM00000100    #test_variable

#BBSM00000100 (bbsim) ISKT71e81998 ...

#Tech profile

${num_of_tech_profiles}=  2

${tech_profile_name0}=  service/voltha/technology_profiles/XGS-PON/64
${tech_profile_data0}=  { \"name\": \"1Service\", \"profile_type\": \"XPON\", \"version\": 1.0, \"num_gem_ports\": 1, \"instance_control\": {\"onu\": \"multi-instance\",\"uni\": \"multi-instance\",\"max_gem_payload_size\": \"auto\" }, \"us_scheduler\": {\"additional_bw\": \"AdditionalBW_BestEffort\",\"direction\": \"UPSTREAM\",\"priority\": 0,\"weight\": 0,\"q_sched_policy\": \"hybrid\" }, \"ds_scheduler\": {\"additional_bw\": \"AdditionalBW_BestEffort\",\"direction\": \"DOWNSTREAM\",\"priority\": 0,\"weight\": 0,\"q_sched_policy\": \"hybrid\" }, \"upstream_gem_port_attribute_list\": [{\"pbit_map\": \"0b01000000\",\"aes_encryption\": \"True\",\"scheduling_policy\": \"StrictPriority\",\"priority_q\": 3,\"weight\": 25,\"discard_policy\": \"TailDrop\",\"max_q_size\": \"auto\",\"discard_config\": {\"max_threshold\": 0,\"min_threshold\": 0,\"max_probability\": 0} } ], \"downstream_gem_port_attribute_list\": [{\"pbit_map\": \"0b11111111\",\"aes_encryption\": \"True\",\"scheduling_policy\": \"StrictPriority\",\"priority_q\": 3,\"weight\": 25,\"discard_policy\": \"TailDrop\",\"max_q_size\": \"auto\",\"discard_config\": {\"max_threshold\": 0,\"min_threshold\": 0,\"max_probability\": 0} } ]}
${tech_profile_name1}=  service/voltha/technology_profiles/XGS-PON/65
${tech_profile_data1}=  { \"name\": \"1Service\", \"profile_type\": \"XPON\", \"version\": 1.0, \"num_gem_ports\": 1, \"instance_control\": {\"onu\": \"multi-instance\",\"uni\": \"multi-instance\",\"max_gem_payload_size\": \"auto\" }, \"us_scheduler\": {\"additional_bw\": \"AdditionalBW_BestEffort\",\"direction\": \"UPSTREAM\",\"priority\": 0,\"weight\": 0,\"q_sched_policy\": \"hybrid\" }, \"ds_scheduler\": {\"additional_bw\": \"AdditionalBW_BestEffort\",\"direction\": \"DOWNSTREAM\",\"priority\": 0,\"weight\": 0,\"q_sched_policy\": \"hybrid\" }, \"upstream_gem_port_attribute_list\": [{\"pbit_map\": \"0b10000000\",\"aes_encryption\": \"True\", \"scheduling_policy\": \"WRR\",\"priority_q\": 2,\"weight\": 30,\"discard_policy\": \"TailDrop\",\"max_q_size\": \"auto\", \"discard_config\": {\"max_threshold\": 0,\"min_threshold\": 0,\"max_probability\": 0} } ], \"downstream_gem_port_attribute_list\": [{\"pbit_map\": \"0b11111111\",\"aes_encryption\": \"True\",\"scheduling_policy\": \"WRR\",\"priority_q\": 2,\"weight\": 30,\"discard_policy\": \"TailDrop\",\"max_q_size\": \"auto\",\"discard_config\": {\"max_threshold\": 0,\"min_threshold\": 0,\"max_probability\": 0} } ]}
#    "name" : "service/voltha/technology_profiles/XGS-PON/64",
#	"data" : "{ \"name\": \"1Service\", \"profile_type\": \"XPON\", \"version\": 1.0, \"num_gem_ports\": 1, \"instance_control\": {\"onu\": \"multi-instance\",\"uni\": \"multi-instance\",\"max_gem_payload_size\": \"auto\" }, \"us_scheduler\": {\"additional_bw\": \"AdditionalBW_BestEffort\",\"direction\": \"UPSTREAM\",\"priority\": 0,\"weight\": 0,\"q_sched_policy\": \"hybrid\" }, \"ds_scheduler\": {\"additional_bw\": \"AdditionalBW_BestEffort\",\"direction\": \"DOWNSTREAM\",\"priority\": 0,\"weight\": 0,\"q_sched_policy\": \"hybrid\" }, \"upstream_gem_port_attribute_list\": [{\"pbit_map\": \"0b01000000\",\"aes_encryption\": \"True\",\"scheduling_policy\": \"StrictPriority\",\"priority_q\": 3,\"weight\": 25,\"discard_policy\": \"TailDrop\",\"max_q_size\": \"auto\",\"discard_config\": {\"max_threshold\": 0,\"min_threshold\": 0,\"max_probability\": 0} } ], \"downstream_gem_port_attribute_list\": [{\"pbit_map\": \"0b01000000\",\"aes_encryption\": \"True\",\"scheduling_policy\": \"StrictPriority\",\"priority_q\": 3,\"weight\": 25,\"discard_policy\": \"TailDrop\",\"max_q_size\": \"auto\",\"discard_config\": {\"max_threshold\": 0,\"min_threshold\": 0,\"max_probability\": 0} } ]}"
#
#    "name" : "service/voltha/technology_profiles/XGS-PON/65",
#	"data" : "{ \"name\": \"1Service\", \"profile_type\": \"XPON\", \"version\": 1.0, \"num_gem_ports\": 1, \"instance_control\": {\"onu\": \"multi-instance\",\"uni\": \"multi-instance\",\"max_gem_payload_size\": \"auto\" }, \"us_scheduler\": {\"additional_bw\": \"auto\",\"direction\": \"UPSTREAM\",\"priority\": 0,\"weight\": 0,\"q_sched_policy\": \"hybrid\" }, \"ds_scheduler\": {\"additional_bw\": \"auto\",\"direction\": \"DOWNSTREAM\",\"priority\": 0,\"weight\": 0,\"q_sched_policy\": \"hybrid\" }, \"upstream_gem_port_attribute_list\": [{\"pbit_map\": \"0b10000000\",\"aes_encryption\": \"True\", \"scheduling_policy\": \"WRR\",\"priority_q\": 2,\"weight\": 30,\"discard_policy\": \"TailDrop\",\"max_q_size\": \"auto\", \"discard_config\": {\"max_threshold\": 0,\"min_threshold\": 0,\"max_probability\": 0} } ], \"downstream_gem_port_attribute_list\": [{\"pbit_map\": \"0b11111111\",\"aes_encryption\": \"True\",\"scheduling_policy\": \"WRR\",\"priority_q\": 2,\"weight\": 30,\"discard_policy\": \"TailDrop\",\"max_q_size\": \"auto\",\"discard_config\": {\"max_threshold\": 0,\"min_threshold\": 0,\"max_probability\": 0} } ]}"

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
${subscriber_macAddress}=  00:02:61:82:30:e5
${subscriber_clli}=  ${clli}
${Subscriber_slotNumber}=  ${ONT_slotNumber}
${subscriber_portNumber}=  ${ONT_ponPortNumber}
${subscriber_ontNumber}=  ${ontNumber}
${subscriber_uniPortNumber}=  2064
#ÇEKCEZ
${subscriber_services_name}=  HSIA
${subscriber_services_stag}=  10
#10 hsi 1546 voip
${subscriber_services_ctag}=  101
#101 hsi 46 voip
${subscriber_services_usctagPriority}=  6
${subscriber_services_usstagPriority}=  6
#${subscriber_services_dsctagPriority}=  6
#${subscriber_services_dsstagPriority}=  6
${subscriber_services_defaultVlan}=  35
${subscriber_services_technologyProfileId}=  1
${subscriber_services_upStreamProfileId}=  4
${subscriber_services_downStreamProfileId}=  1
${subscriber_services_useDstMac}=  false

#${subscriber_services}=  [{ "name" : "${subscriber_services_name}", "stag" : ${subscriber_services_stag}, "ctag" : ${subscriber_services_ctag}, "usctagPriority" : ${subscriber_services_usctagPriority}, "usstagPriority" : ${subscriber_services_usstagPriority}, "dsctagPriority" : ${subscriber_services_dsctagPriority}, "dsstagPriority" : ${subscriber_services_dsstagPriority}, "defaultVlan" : ${subscriber_services_defaultVlan}, "technologyProfileId" : ${subscriber_services_technologyProfileId}, "upStreamProfileId" : ${subscriber_services_upStreamProfileId}, "downStreamProfileId" : ${subscriber_services_downStreamProfileId}, "useDstMac":"${subscriber_services_useDstMac}" }]
${subscriber_services}=  [{ "name" : "${subscriber_services_name}", "stag" : ${subscriber_services_stag}, "ctag" : ${subscriber_services_ctag}, "usctagPriority" : ${subscriber_services_usctagPriority}, "usstagPriority" : ${subscriber_services_usstagPriority}, "defaultVlan" : ${subscriber_services_defaultVlan}, "technologyProfileId" : ${subscriber_services_technologyProfileId}, "upStreamProfileId" : ${subscriber_services_upStreamProfileId}, "downStreamProfileId" : ${subscriber_services_downStreamProfileId}, "useDstMac":"${subscriber_services_useDstMac}" }]
