#!/usr/bin/env bash
#
scp siemanalyst@chpbdaodi02.prod.ch.perform.local:~/notebooks/siem/product_model_bin/m25/v4/mojo/h2o-genmodel.jar .
scp siemanalyst@chpbdaodi02.prod.ch.perform.local:~/notebooks/siem/product_model_bin/m25/v4/mojo/DRF_1_AutoML_20181129_143230.zip .
cp DRF_1_AutoML_20181129_143230.zip ../src/main/resources/ai/h2o/hive/udf/
#
