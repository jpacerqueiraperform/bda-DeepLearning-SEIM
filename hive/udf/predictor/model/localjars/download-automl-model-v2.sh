#!/usr/bin/env bash
#
##### scp siemanalyst@chpbdaodi02.prod.ch.perform.local:~/notebooks/siem/product_model_bin/m20/mojo/h2o-genmodel.jar .
##### scp siemanalyst@chpbdaodi02.prod.ch.perform.local:~/notebooks/siem/product_model_bin/m20/mojo/StackedEnsemble_AllModels_AutoML_20181115_150840.zip .
##### cp StackedEnsemble_AllModels_AutoML_20181115_150840.zip ../src/main/resources/ai/h2o/hive/udf/
#
scp siemanalyst@chpbdaodi02.prod.ch.perform.local:~/notebooks/siem/product_model_bin/m20/v2/mojo/h2o-genmodel.jar .
scp siemanalyst@chpbdaodi02.prod.ch.perform.local:~/notebooks/siem/product_model_bin/m20/v2/mojo/*_AutoML_*.zip .
cp *_AutoML_*.zip ../src/main/resources/ai/h2o/hive/udf/
#
