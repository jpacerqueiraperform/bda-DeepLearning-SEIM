use siem;
show tables;
create external table if not exists siem.urlappcontrollogs (
time string,description string,interfacename string,interfacedirection string,interface string,action string,matchedcategory string,applicationdescription string,applicationid string,applicationproperties string,applicationrisk string,applicationruleid string,applicationsignatureid string,applicationname string,destination string,primarycategory string,origin string,policydate string,policymanagement string,policyname string,blade string,productfamily string,protocol string,proxysourceip string,resource string,sourceport string,destinationport string,servicename string,source string,type string,usercheckid string,clienttype string,reason string,browsetime string,totalbytes string,receivedbytes string,sentbytes string,suppressedlogs string,applicationrulename string,dlpincidentuid string,frequency string,logid string,usercheckmessagetouser string,confirmationscope string,servertype string,referrer_self_uid string)
     partitioned by (dt int)
     row format delimited
     fields terminated by ','
     stored as textfile
     location '/user/siemanalyst/datawarehouse/urlappcontrollogs';
