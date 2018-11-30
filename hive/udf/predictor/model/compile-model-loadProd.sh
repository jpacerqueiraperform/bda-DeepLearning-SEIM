mvn -X clean install  -Dmaven.test.skip=true
mvn -X package -Dmaven.test.skip=true
scp localjars/h2o-genmodel.jar siemanalyst@chpbdaodi02.prod.ch.perform.local:~/notebooks/siem/pyspark_clean_data/spark_jars/
scp target/ScoreDataUDFAUTOML-4.0-SNAPSHOT.jar siemanalyst@chpbdaodi02.prod.ch.perform.local:~/notebooks/siem/pyspark_clean_data/spark_jars/ 
