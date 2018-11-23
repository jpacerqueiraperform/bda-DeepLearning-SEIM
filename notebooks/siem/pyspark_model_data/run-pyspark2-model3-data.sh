#!/bin/bash
MY_FOLDER="/home/siemanalyst/notebooks/siem/pyspark_model_data"
#
### MODEL:3
## Stage urltopredict folder
spark2-submit --master yarn --deploy-mode client $MY_FOLDER/version3-phishingURL-Clean-AUTOML-V3-BestModel-Discovery.py
## Stage url_ml_score_predict
rm -rf /home/siemanalyst/notebooks/siem/product_model_bin/m40/v3/*
spark2-submit --master yarn --deploy-mode client $MY_FOLDER/version3-phishingURL-ModelBuild-AUTOML-V3-BestModel-Discovery.py
#
