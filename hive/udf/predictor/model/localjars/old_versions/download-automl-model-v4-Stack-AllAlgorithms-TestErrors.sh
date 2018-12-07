#!/usr/bin/env bash
#
scp siemanalyst@chpbdaodi02.prod.ch.perform.local:~/notebooks/siem/product_model_bin/m25/v4/mojo/h2o-genmodel.jar .
scp siemanalyst@chpbdaodi02.prod.ch.perform.local:~/notebooks/siem/product_model_bin/m25/v4/mojo/StackedEnsemble_AllModels_AutoML_20181207_142115.zip .
cp StackedEnsemble_AllModels_AutoML_20181207_142115.zip ../src/main/resources/ai/h2o/hive/udf/
#
