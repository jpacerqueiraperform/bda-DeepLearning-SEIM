#!/bin/bash
MY_FOLDER="/home/siemanalyst/notebooks/siem/pyspark_model_data"
#
### MODEL:3
## Stage urltopredict folder
rm -rf /home/siemanalyst/notebooks/siem/product_model_bin/m40/v4/*
spark2-submit --master yarn --deploy-mode client $MY_FOLDER/version4-phishingURL-Clean-AUTOML-V4-BestModel-Discovery.py
## Stage url_ml_score_predict
spark2-submit --master yarn --deploy-mode client $MY_FOLDER/version4-phishingURL-ModelBuild-AUTOML-V4-BestModel-Discovery.py
#
