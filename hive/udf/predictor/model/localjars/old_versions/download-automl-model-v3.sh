#!/usr/bin/env bash
#
scp siemanalyst@chpbdaodi02.prod.ch.perform.local:~/notebooks/siem/product_model_bin/m40/v3/mojo/h2o-genmodel.jar .
scp siemanalyst@chpbdaodi02.prod.ch.perform.local:~/notebooks/siem/product_model_bin/m40/v3/mojo/GBM_4_AutoML_20181123_204136.zip .
cp GBM_4_AutoML_20181123_204136.zip ../src/main/resources/ai/h2o/hive/udf/
#
