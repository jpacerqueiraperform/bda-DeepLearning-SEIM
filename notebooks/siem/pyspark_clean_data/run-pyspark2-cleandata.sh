#spark2-submit --master yarn --deploy-mode client cleandata.py
#spark2-submit --master yarn --deploy-mode client  import-to-urltopredict.py
#spark2-submit --master yarn --deploy-mode client --jars $PWD/spark_jars/ScoreDataUDFAUTOML-2.0-SNAPSHOT.jar,$PWD/spark_jars/h2o-genmodel.jar  import-to-urlpredictions.py
MY_FOLDER="/home/siemanalyst/notebooks/siem/pyspark_clean_data"

spark2-submit --master yarn --deploy-mode client $MY_FOLDER/cleandata.py
spark2-submit --master yarn --deploy-mode client --jars $MY_FOLDER/spark_jars/ScoreDataUDFAUTOML-2.0-SNAPSHOT.jar,$MY_FOLDER/spark_jars/h2o-genmodel.jar  $MY_FOLDER/import-to-urlpredictions.py
