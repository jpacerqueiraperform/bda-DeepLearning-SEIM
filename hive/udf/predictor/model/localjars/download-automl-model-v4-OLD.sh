#!/usr/bin/env bash
#
scp siemanalyst@chpbdaodi02.prod.ch.perform.local:~/notebooks/siem/product_model_bin/m25/v4/mojo/h2o-genmodel.jar .
scp siemanalyst@chpbdaodi02.prod.ch.perform.local:~/notebooks/siem/product_model_bin/m25/v4/mojo/XGBoost_grid_1_AutoML_20181129_193540_model_2.zip .
cp XGBoost_grid_1_AutoML_20181129_193540_model_2.zip ../src/main/resources/ai/h2o/hive/udf/
#
