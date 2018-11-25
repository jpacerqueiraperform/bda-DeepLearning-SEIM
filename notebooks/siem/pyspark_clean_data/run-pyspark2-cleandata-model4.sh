#!/bin/bash
MY_FOLDER="/home/siemanalyst/notebooks/siem/pyspark_clean_data"
##
### MODEL:4
## Stage urltopredict folder
spark2-submit --master yarn --deploy-mode client $MY_FOLDER/cleandata-model4-19functions.py > $MY_FOLDER/model4-cleandata-lastrun.log
## Stage url_ml_score_predict
spark2-submit --master yarn --deploy-mode client --jars $MY_FOLDER/spark_jars/ScoreDataUDFAUTOML-4.0-SNAPSHOT.jar,$MY_FOLDER/spark_jars/h2o-genmodel.jar  $MY_FOLDER/import-TableAs-model4-19functions.py >> $MY_FOLDER/model4-cleandata-lastrun.log
#