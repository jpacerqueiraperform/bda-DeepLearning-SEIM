#!/usr/bin/env bash
#
scp siemanalyst@chpbdaodi02.prod.ch.perform.local:~/notebooks/siem/product_model_bin/m40/v4/mojo/h2o-genmodel.jar .
scp siemanalyst@chpbdaodi02.prod.ch.perform.local:~/notebooks/siem/product_model_bin/m40/v4/mojo/*_AutoML_*_*.zip .
cp *_AutoML_*_*.zip ../src/main/resources/ai/h2o/hive/udf/
#
