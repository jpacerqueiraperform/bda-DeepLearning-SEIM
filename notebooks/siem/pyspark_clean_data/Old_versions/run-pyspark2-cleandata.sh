#!/bin/bash
MY_FOLDER="/home/siemanalyst/notebooks/siem/pyspark_clean_data"
#
### MODEL:1, MODEL:2
#spark2-submit --master yarn --deploy-mode client $MY_FOLDER/cleandata.py
#spark2-submit --master yarn --deploy-mode client --jars $MY_FOLDER/spark_jars/ScoreDataUDFAUTOML-2.0-SNAPSHOT.jar,$MY_FOLDER/spark_jars/h2o-genmodel.jar  $MY_FOLDER/import-to-urlpredictions.py
#
### MODEL:3
## Stage urltopredict folder
spark2-submit --master yarn --deploy-mode client $MY_FOLDER/cleandata-model3-func15.py > $MY_FOLDER/model3-cleandata-lastrun.log
## Stage url_ml_score_predict
spark2-submit --master yarn --deploy-mode client --jars $MY_FOLDER/spark_jars/ScoreDataUDFAUTOML-3.0-SNAPSHOT.jar,$MY_FOLDER/spark_jars/h2o-genmodel.jar  $MY_FOLDER/import-to-urlpredictions-model3-func15.py >> $MY_FOLDER/model3-cleandata-lastrun.log
#