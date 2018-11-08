use siem;
show tables;
create external table if not exists siem.antivirusantibot (time string,description string,interfacename string,interfacedirection  string,interface string,action string,confidencelevel string,descriptiondns string,destinationdnshostname string,destination string,logid string,malwareaction string,malwareruleid string,origin string,policydate string,policymanagement string,policyname string,blade string,productfamily string,protectionname string,protectiontype string,protectionid string,protocol string,receivedbytes string,remediation_options string,sourceport string,scope string,sentbytes string,destinationport string,servicename string,sessionidentification string,severity string,sourceos string,source string,suppressedlogs string,type string,vendor_list string,malwarefamily string,packet_capture_name string,packet_capture_time string,packet_capture_unique_id string,rulename string,ruleuid string,proxysourceip string,resource string,clienttype string,treatmentresult string,reason string,updatestatus string,contract_name string,specialproperties string,subscriptionexpiration string,subscription_stat string,subscription_stat_desc string,dlpincidentuid string,frequency string,usercheckmessagetouser string,confirmationscope string,usercheckid string)
     partitioned by (dt int)
     row format delimited
     fields terminated by ','
     stored as textfile
     location '/user/siemanalyst/datawarehouse/antivirusantibot';
