use siem;
show tables;
create external table if not exists siem.ipslogs (
time string,interfacename string,interfacedirection  string ,interface string,description string,origin string,policydate string,policymanagement string,policyname string,blade string,productfamily string,type string,descriptiony string,attackname string,attackinformation string,confidencelevel string,destination string,industryreference string,performanceimpact string,protectionname string,protectiontype string,protectionid string,protocol string,rule string,ruleuid string,severity string,ipsprofile string,source string,suppressedlogs string,totallogs string,action string,sourceport string,destinationport string,servicename string,tcpflags string)
     partitioned by (dt int)
     row format delimited
     fields terminated by ','
     stored as textfile
     location '/user/siemanalyst/datawarehouse/ipslogs';
