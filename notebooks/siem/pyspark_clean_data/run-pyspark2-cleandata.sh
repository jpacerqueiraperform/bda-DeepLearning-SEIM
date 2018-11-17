#spark2-submit --master yarn --deploy-mode client cleandata.py
#spark2-submit --master yarn --deploy-mode client  import-to-urltopredict.py
spark2-submit --master yarn --deploy-mode client --jars $PWD/spark_jars/ScoreDataUDFAUTOML-2.0-SNAPSHOT.jar,$PWD/spark_jars/h2o-genmodel.jar  import-to-urlpredictions.py
