#!/bin/bash
MY_FOLDER="/home/siemanalyst/notebooks/siem/pyspark_model_data"
#
### MODEL:4
## Stage urltopredict folder
unset http_proxy
spark2-submit --master yarn --deploy-mode client $MY_FOLDER/version4-phishingURL-Clean-AUTOML-V4-BestModel-Discovery.py > $MY_FOLDER/ModelBuild-AUTOML-V4-LastRun.log
## Rebuild Model url_ml_score_predict under AutoMl 25Models
rm -rf /home/siemanalyst/notebooks/siem/product_model_bin/m25/v4/*
spark2-submit --master yarn --deploy-mode client $MY_FOLDER/version4-phishingURL-RebuildModel4-AUTOML-BestModel-Discovery.py >> $MY_FOLDER/ModelBuild-AUTOML-V4-LastRun.log
#
