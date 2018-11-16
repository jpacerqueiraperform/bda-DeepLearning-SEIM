
## Hive UDF POJO Example

## Example - R-Studio SparklyR H20.ai  - Opta Gateway 

1. Generated Model from R-Studio s§ession in Spark and H20 Context for YARN in the bda cluster 
2. Model generation of R session https://stash.performgroup.com/projects/BDA/repos/bda_exadata_samples/browse/SAMPLE_IXPBDAOPTA01_TOOLS/jpac-sparklyr/rstudio_jobs/hive_udf_pojo_template/GBM_DeepLearning_Plotting_POJO_Export.R
3. Tutorial explained online https://github.com/h2oai/h2o-tutorials/blob/master/tutorials/hive_udf_template/hive_udf_pojo_template/pom.xml



## Hive UDF POJO Example - Tutorial Explained

This tutorial describes how to use a model created in H2O to create a Hive UDF (user-defined function) for scoring data.   While the fastest scoring typically results from ingesting data files in HDFS directly into H2O for scoring, there may be several motivations not to do so.  For example, the clusters used for model building may be research clusters, and the data to be scored may be on "production" clusters.  In other cases, the final data set to be scored may be too large to reasonably score in-memory.  To help with these kinds of cases, this document walks through how to take a scoring model from H2O, plug it into a template UDF project, and use it to score in Hive.  All the code needed for this walkthrough can be found in this repository branch.

## The Goal
The desired work flow for this task is:

1. Load training and test data into H2O
2. Create several models in H2O
3. Export the best model as a [POJO](https://en.wikipedia.org/wiki/Plain_Old_Java_Object)
4. Compile the H2O model as a part of the UDF project
5. Copy the UDF to the cluster and load into Hive
6. Score with your UDF

For steps 1-3, we will give instructions scoring the data through R.  We will add a step between 4 and 5 to load some test data for this example.

## Requirements

This tutorial assumes the following:

1. Some familiarity with using H2O in R.  Getting started tutorials can be found [here](http://docs.0xdata.com/newuser/top.html).
2. The ability to compile Java code.  The repository provides a pom.xml file, so using Maven will be the simplest way to compile, but IntelliJ IDEA will also read in this file.  If another build system is preferred, it is left to the reader to figure out the compilation details.
3. A working Hive install to test the results.

## The Data

For this post, we will be using the H2O conviva cancer evaluation dataset conviva.csv

The goal of the analysis in this demo is to predict if the VOL of your conviva increases according to the evolution of your proteins in the blog level and your age and race conditions .  The columns we will be using are:

* AGE:  age


## Building the Model in R
No need to cut and paste code: the complete R script described below is part of this git repository (GBM-example.R).
### Load the training and test data into H2O
Since we are playing with a small data set for this example, we will start H2O locally and load the datasets:

## Building the Model in R
No need to cut and paste code: the complete R script described below is part of this git repository (GBM-example.R).
### Load the training and test data into H2O
Since we are playing with a small data set for this example, we will start H2O locally and load the datasets:

```r

#
# DeepLearning
library(dplyr)
library(sparklyr)
library(h2o)
options(rsparkling.sparklingwater.version = "2.1.27",rsparkling.sparklingwater.location = "/home/analyticsdb/spark/sparklingwater/sparkling-water-2.1.27/assembly/build/libs/sparkling-water-assembly_2.11-2.1.27-all.jar")
library(rsparkling)

ip <- as.data.frame(installed.packages()[,c(1,3:4)])
ip <- ip[is.na(ip$Priority),1:2,drop=FALSE]
print(ip, row.names=FALSE)
rownames(ip) <- NULL

# h2o to be restarted in every session
h2o.shutdown()
# h2o port is redirected from 54321 to 54323 for spark mode=local
#
h2o.init(ip = "localhost", port = 54321, startH2O = TRUE,
         forceDL = FALSE, enable_assertions = TRUE, license = NULL,
         nthreads = 2, max_mem_size = NULL, min_mem_size = NULL,
         ice_root = tempdir(), strict_version_check = TRUE,
         proxy = NA_character_, https = FALSE, insecure = FALSE,
         username = NA_character_ , password = NA_character_ ,
         cookies = NA_character_, context_path = NA_character_ )

h2o.clusterInfo()
spark_home_dir()

# restart r session
#sessionInfo()
#options(rsparkling.sparklingwater.version = "1.6.2")
#spark_install(version = "1.6.2")
#spark_home_set(path="/home/analyticsdb/spark/spark-1.6.2-bin-hadoop2.6")
#sc <- spark_connect(master = "local", version = "1.6.2", config = list(sparklyr.log.console = TRUE))

# FIX FROM GITGUB : https://github.com/rstudio/sparklyr/issues/801
# FIX PROXY SERVER for SPARK2
#sessionInfo()
#devtools::install_github("rstudio/sparklyr")

# restart r session
sessionInfo()
# Match rsparkling with spark2.1 and H2O verison from https://github.com/h2oai/rsparkling/blob/master/README.md 
# Download from : http://h2o-release.s3.amazonaws.com/sparkling-water/rel-2.1/27/index.html 
# Wait for 15 minutes, might require even more.
# Load parameters from condaR zip

#spark_home_set(path="/home/analyticsdb/spark/spark-2.1.0-bin-hadoop2.7")

config <- spark_config()
spark_home <- "/home/analyticsdb/spark/spark-2.1.0-bin-hadoop2.7"
spark_version <- "2.1.0"
config$spark.executor.cores=1
config$spark.executor.memory="1g"
config$`sparklyr.shell.driver-memory` <- "1g"
config$`sparklyr.shell.executor-memory` <- "1g"
config$spark.executor.instances=2
config$spark.driver.memory="2g"
config$spark.driver.cores   <- 2
config$spark.dynamicAllocation.enabled='false'
config[["spark.r.command"]] <- "/home/analyticsdb/spark/spark-2.1.0-bin-hadoop2.7/r_env.zip/r_env/bin/Rscript"
config[["spark.yarn.dist.archives"]] <- "/home/analyticsdb/spark/spark-2.1.0-bin-hadoop2.7/r_env.zip"
config$sparklyr.apply.env.R_HOME <- "./home/analyticsdb/spark/spark-2.1.0-bin-hadoop2.7/r_env.zip/r_env/lib/R"
config$sparklyr.apply.env.RHOME <- "./home/analyticsdb/spark/spark-2.1.0-bin-hadoop2.7/r_env.zip/r_env"
config$sparklyr.apply.env.R_SHARE_DIR <- "./home/analyticsdb/spark/spark-2.1.0-bin-hadoop2.7/r_env.zip/r_env/lib/R/share"
config$sparklyr.apply.env.R_INCLUDE_DIR <- "./home/analyticsdb/spark/spark-2.1.0-bin-hadoop2.7/r_env.zip/r_env/lib/R/include"
config$sparklyr.apply.env.LD_LIBRARY_PATH <- "/opt/cloudera/parcels/Anaconda/lib"
config$sparklyr.apply.env.PYTHONPATH <- "./home/analyticsdb/spark/spark-2.1.0-bin-hadoop2.7/r_env.zip/r_env/lib/python2.7/site/packages"
# Force Driver and host from gateway
config$spark.jars <- "file:/data/analyticsdb/spark/sparklingwater/sparkling-water-2.1.27/assembly/build/libs/sparkling-water-assembly_2.11-2.1.27-all.jar,file:/usr/lib64/R/library/sparklyr/java/sparklyr-2.1-2.11.jar"
config$spark.driver.host <- "10.12.61.19"
# ISSUE https://github.com/h2oai/sparkling-water/issues/32
config$spark.ext.h2o.topology.change.listener.enabled <- TRUE
config$spark.ext.h2o.ip <- "localhost"
config$spark.ext.h2o.nthreads <- 2
config$spark.ext.h2o.port <- 54321
# ISSUE https://github.com/h2oai/sparkling-water/issues/466
config$spark.executor.heartbeatInterval <- 6000
config$sparklyr.gateway.start.timeout <- 6000
### Enable visualization of detailed logs
#config$sparklyr.log.console <- TRUE
config$sparklyr.log.console <- FALSE

system.time(sc <- spark_connect(master = "yarn-client", app_name = "jpac-sparklyr", version = spark_version, config = config, spark_home=spark_home))
#system.time(sc <- spark_connect(master = "local", app_name = "jpac-sparklyr", version = spark_version , config = config, spark_home=spark_home))

spark_context(sc)
spark_context_config(sc)

## ISSUE : https://github.com/h2oai/sparkling-water/issues/32
h2o_context(sc)

conviva_file <- read.csv("/home/analyticsdb/projects/r-studio/AVG_Bitrate/conviva11.csv")
head(conviva_file)

conviva_csv_df <- spark_read_csv(sc,"conviva","hdfs://bda-ns//user/analyticsdb/conviva11.csv")
head(conviva_csv_df)

actual_conviva_df <- conviva_csv_df %>%
  select(average_bitrate_kbps) %>%
  collect() %>%
  `[[`("average_bitrate_kbps")
head(actual_conviva_df)

conviva_tbl <- copy_to(sc, conviva_csv_df, "conviva_tbl", overwrite = TRUE)
head(conviva_tbl)

#Convert to an H2O Frame:
conviva_hf <- as.h2o(conviva_tbl)

#
# Test 1  :Model: Deep Neural Network
#
splits <- h2o.splitFrame(conviva_hf, seed = 1099)

y <- "average_bitrate_kbps"
#remove response and ID cols
x <- setdiff(names(conviva_hf), c("viewerId", y))
# Print Header of the Variables
x

# Train a Deep Neural Network
dl_fit <- h2o.deeplearning(x = x, y = y,
                           training_frame = splits[[1]],
                           epochs = 999,
                           activation = "Rectifier",
                           hidden = c(10, 5, 10),
                           input_dropout_ratio = 0.78)

h2o.performance(dl_fit, newdata = splits[[2]])

# Apply prediction from the achieved Model
pred_model_dl_fit <- h2o.predict(dl_fit, newdata = conviva_hf)
head(pred_model_dl_fit)
head(conviva_hf)

predicted_model_dl_fit <- as.data.frame(pred_model_dl_fit)

actual_conviva_df <- conviva_csv_df %>%
  select(average_bitrate_kbps) %>%
  collect() %>%
  `[[`("average_bitrate_kbps")
head(actual_conviva_df)

# produce a data.frame housing our predicted + actual values of AVGBITRATE  actual_conviva_df
data <- data.frame(
  predicted = predicted_model_dl_fit,
  actual    = actual_conviva_df)

# a bug in data.frame does not set colnames properly; reset here 
names(data) <- c("predicted", "actual")

# plot predicted vs. actual values
ggplot(data, aes(x = actual, y = predicted)) +
  geom_abline(lty = "dashed", col = "red") +
  geom_point() +
  theme(plot.title = element_text(hjust = 0.3)) +
  coord_fixed(ratio = 3.0) +
  labs(
    x = "Actual AVG BitRate",
    y = "Predicted AVG BitRate",
    title = "DL-FIT Predicted vs. Actual AVG BitRate"
  )

#
# Test 2  :Model: GBM (Gradient Boost Machine)
#
# Cartesian Grid Search
# New Split
splits <- h2o.splitFrame(conviva_hf, seed = 999999)

y <- "average_bitrate_kbps"
#remove response and ID cols
x <- setdiff(names(conviva_hf), c("viewerId", y))
# Print Header of the Variables
x

# GBM hyperparamters
gbm_params1 <- list(learn_rate = c(0.5, 1.0),
                    max_depth = c(3, 5, 9),
                    sample_rate = c(0.8, 1.0),
                    col_sample_rate = c(0.1, 0.5, 1.0))

# Takes 2 minutes to obtain the grid of models
# Models available later in http://ixpbdaopta01.prod.ix.perform.local:54321/flow/index.html 
#
# Train and validate a grid of GBMs
gbm_grid1 <- h2o.grid("gbm", x = x, y = y,
                      grid_id = "gbm_grid1",
                      training_frame = splits[[1]],
                      validation_frame = splits[[1]],
                      ntrees = 1000,
                      seed = 999999,
                      hyper_params = gbm_params1)

# Get the grid results, sorted by validation MSE
gbm_gridperf1 <- h2o.getGrid(grid_id = "gbm_grid1", 
                             sort_by = "mse", 
                             decreasing = FALSE)

# Print grid results
print(gbm_gridperf1)

# best model in grid according to mse
gbm_gridperf1@model_ids[[1]]

gbm_model_gridperf1 <- h2o.getModel(gbm_gridperf1@model_ids[[1]])

#Apply prediction from the best MSE qualifyed Model
pred_model_gridperf1 <- h2o.predict(gbm_model_gridperf1, newdata = conviva_hf)

head(pred_model_gridperf1)

predicted_model_gridperf1 <- as.data.frame(pred_model_gridperf1)

actual_conviva_df <- conviva_csv_df %>%
  select(average_bitrate_kbps) %>%
  collect() %>%
  `[[`("average_bitrate_kbps")
head(actual_conviva_df)

# produce a data.frame housing our predicted + actual 'VOL' values of conviva_df
data <- data.frame(
  predicted = predicted_model_gridperf1,
  actual    = actual_conviva_df)

# a bug in data.frame does not set colnames properly; reset here 
names(data) <- c("predicted", "actual")

# plot predicted vs. actual values
ggplot(data, aes(x = actual, y = predicted)) +
  geom_abline(lty = "dashed", col = "red") +
  geom_point() +
  theme(plot.title = element_text(hjust = 0.8)) +
  coord_fixed(ratio = 3.5) +
  labs(
    x = "Actual AVG BitRate",
    y = "Predicted AVG BitRate",
    title = "CGRID-GBM-MSE_1 Predicted vs. Actual AVG BitRate" )

# local Dir in node home/analyticsdb for external storage of model
tmpdir_model <- "h2omodels-v1-avg-bitrate"
dir.create(tmpdir_model)
# print the centroid statistics
h2o.centroid_stats(gbm_model_gridperf1)
# Save generic Model
h2o.saveModel(gbm_model_gridperf1, path = tmpdir_model)
# Export Model as a POJO with H2O
h2o.download_pojo(gbm_model_gridperf1, path = tmpdir_model)
# Export Model as a MOJO with H2O
h2o.download_mojo(gbm_model_gridperf1, path = tmpdir_model)
y
x

```

### Creating several models in H2O
Now that the data has been prepared, let's build a set of models using [GBM](http://h2o-release.s3.amazonaws.com/h2o/rel-wolpert/8/docs-website/h2o-docs/index.html#Data%20Science%20Algorithms-GBM).  Here we will select the columns used as predictors and results, specify the validation data set, and then build a model.

```r
# ... with more rows
>
> conviva_hf <- as.h2o(conviva_tbl)
  |=======================================================================================================================| 100%
> splits <- h2o.splitFrame(conviva_hf, seed = 1099)
> y <- "VOL"
> x <- setdiff(names(conviva_hf), c("ID", y))
> y
[1] "average_bitrate_kbps"
> x
 [1] "asset"                "deviceos"             "country"              "state"                "city"                
 [6] "asn"                  "isp"                  "start_time_unix_time" "startup_time_ms"      "playing_time_ms"     
[11] "buffering_time_ms"    "interrupts"           "startup_error"        "session_tags"         "ip_address"          
[16] "cdn"                  "browser"              "conviva_session_id"   "stream_url"           "error_list"          
[21] "percentage_complete" 
> 
> splits <- h2o.splitFrame(conviva_hf, seed = 999999)
> y <- "average_bitrate_kbps"
> x <- setdiff(names(conviva_hf), c("viewerId", y))
> x
 [1] "asset"                "deviceos"             "country"              "state"                "city"                
 [6] "asn"                  "isp"                  "start_time_unix_time" "startup_time_ms"      "playing_time_ms"     
[11] "buffering_time_ms"    "interrupts"           "startup_error"        "session_tags"         "ip_address"          
[16] "cdn"                  "browser"              "conviva_session_id"   "stream_url"           "error_list"          
[21] "percentage_complete" 
> gbm_params1 <- list(learn_rate = c(0.5, 1.0),
+                     max_depth = c(3, 5, 9),
+                     sample_rate = c(0.8, 1.0),
+                     col_sample_rate = c(0.1, 0.5, 1.0))
> gbm_grid1 <- h2o.grid("gbm", x = x, y = y,
+                       grid_id = "gbm_grid1",
+                       training_frame = splits[[1]],
+                       validation_frame = splits[[1]],
+                       ntrees = 1000,
+                       seed = 999999,
+                       hyper_params = gbm_params1)
  |======================================================================================================================| 100%
> gbm_gridperf1 <- h2o.getGrid(grid_id = "gbm_grid1", 
+                              sort_by = "mse", 
+                              decreasing = FALSE)
> print(gbm_gridperf1)
H2O Grid Details
================

Grid ID: gbm_grid1 
Used hyper parameters: 
  -  col_sample_rate 
  -  learn_rate 
  -  max_depth 
  -  sample_rate 
Number of models: 36 
Number of failed models: 0 

Hyper-Parameter Search Summary: ordered by increasing mse
  col_sample_rate learn_rate max_depth sample_rate          model_ids                mse
1             1.0        1.0         9         0.8 gbm_grid1_model_17 1.7070928735725395
2             1.0        1.0         9         1.0 gbm_grid1_model_35  3.885195787192853
3             1.0        0.5         9         0.8 gbm_grid1_model_14   14.6332382120918
4             0.5        1.0         9         1.0 gbm_grid1_model_34 15.091995990395183
5             0.5        1.0         9         0.8 gbm_grid1_model_16  28.77310298364047

---
   col_sample_rate learn_rate max_depth sample_rate          model_ids                mse
31             1.0        1.0         3         1.0 gbm_grid1_model_23  1515604.375699007
32             1.0        0.5         3         1.0 gbm_grid1_model_20  1898580.370368388
33             0.1        1.0         3         1.0 gbm_grid1_model_21 2084888.9235499164
34             0.1        1.0         3         0.8  gbm_grid1_model_3 2186015.8911359706
35             0.1        0.5         3         0.8  gbm_grid1_model_0   2685705.45297659
36             0.1        0.5         3         1.0 gbm_grid1_model_18 2717718.5948627125
> gbm_gridperf1@model_ids[[1]]
[1] "gbm_grid1_model_17"
> gbm_model_gridperf1 <- h2o.getModel(gbm_gridperf1@model_ids[[1]])
> 
```

### Model Can be used for scoring (h2o.predict function) and plot helps compare real values with predictions

```r
>
> gbm_gridperf1@model_ids[[1]]
[1] "gbm_grid1_model_17"
> gbm_gridperf1@model_ids[[1]]
[1] "gbm_grid1_model_17"
> gbm_model_gridperf1 <- h2o.getModel(gbm_gridperf1@model_ids[[1]])
> pred_model_gridperf1 <- h2o.predict(gbm_model_gridperf1, newdata = conviva_hf)
  |======================================================================================================================| 100%
> head(pred_model_gridperf1)
    predict
1 1379.4016
2  671.7323
3 1378.9894
4 1378.5837
5  933.0131
6 4457.6422
> predicted_model_gridperf1 <- as.data.frame(pred_model_gridperf1)
> actual_conviva_df <- conviva_csv_df %>%
+   select(average_bitrate_kbps) %>%
+   collect() %>%
+   `[[`("average_bitrate_kbps")
18/06/04 15:24:29 WARN SparkSession$Builder: Using an existing SparkSession; some configuration may not take effect.
18/06/04 15:24:29 INFO SparkSqlParser: Parsing command: SELECT `average_bitrate_kbps`
FROM `conviva`
18/06/04 15:24:29 INFO SparkContext: Starting job: collect at utils.scala:196
18/06/04 15:24:29 INFO DAGScheduler: Got job 15 (collect at utils.scala:196) with 1 output partitions
18/06/04 15:24:29 INFO DAGScheduler: Final stage: ResultStage 19 (collect at utils.scala:196)
18/06/04 15:24:29 INFO DAGScheduler: Parents of final stage: List()
18/06/04 15:24:29 INFO DAGScheduler: Missing parents: List()
18/06/04 15:24:29 INFO DAGScheduler: Submitting ResultStage 19 (MapPartitionsRDD[72] at collect at utils.scala:196), which has no missing parents
18/06/04 15:24:29 INFO MemoryStore: Block broadcast_22 stored as values in memory (estimated size 32.3 KB, free 365.1 MB)
18/06/04 15:24:29 INFO MemoryStore: Block broadcast_22_piece0 stored as bytes in memory (estimated size 12.3 KB, free 365.1 MB)
18/06/04 15:24:29 INFO BlockManagerInfo: Added broadcast_22_piece0 in memory on 10.12.61.19:50570 (size: 12.3 KB, free: 366.2 MB)
18/06/04 15:24:29 INFO SparkContext: Created broadcast 22 from broadcast at DAGScheduler.scala:996
18/06/04 15:24:29 INFO DAGScheduler: Submitting 1 missing tasks from ResultStage 19 (MapPartitionsRDD[72] at collect at utils.scala:196)
18/06/04 15:24:29 INFO YarnScheduler: Adding task set 19.0 with 1 tasks
18/06/04 15:24:29 INFO TaskSetManager: Starting task 0.0 in stage 19.0 (TID 20, ixpbda04.prod.ix.perform.local, executor 1, partition 0, PROCESS_LOCAL, 6773 bytes)
18/06/04 15:24:29 INFO BlockManagerInfo: Added broadcast_22_piece0 in memory on ixpbda04.prod.ix.perform.local:24548 (size: 12.3 KB, free: 363.3 MB)
18/06/04 15:24:29 INFO TaskSetManager: Finished task 0.0 in stage 19.0 (TID 20) in 29 ms on ixpbda04.prod.ix.perform.local (executor 1) (1/1)
18/06/04 15:24:29 INFO YarnScheduler: Removed TaskSet 19.0, whose tasks have all completed, from pool 
18/06/04 15:24:29 INFO DAGScheduler: ResultStage 19 (collect at utils.scala:196) finished in 0.029 s
18/06/04 15:24:29 INFO DAGScheduler: Job 15 finished: collect at utils.scala:196, took 0.034693 s
> head(actual_conviva_df)
[1] 1379  672 1379 1379 1173  672
> data <- data.frame(
+   predicted = predicted_model_gridperf1,
+   actual    = actual_conviva_df)
> names(data) <- c("predicted", "actual")
> ggplot(data, aes(x = actual, y = predicted)) +
+   geom_abline(lty = "dashed", col = "red") +
+   geom_point() +
+   theme(plot.title = element_text(hjust = 0.8)) +
+   coord_fixed(ratio = 3.5) +
+   labs(
+     x = "Actual AVG BitRate",
+     y = "Predicted AVG BitRate",
+     title = "CGRID-GBM-MSE_1 Predicted vs. Actual AVG BitRate" )
Warning message:
Removed 4 rows containing missing values (geom_point). 
>
```

### Export the best model as a POJO
From here, we can download this model as a Java [POJO](https://en.wikipedia.org/wiki/Plain_Old_Java_Object) to a local directory called `generated_model`.

```r
>
> tmpdir_model <- "h2omodels-v1-avg-bitrate"
> dir.create(tmpdir_model)
> h2o.centroid_stats(gbm_model_gridperf1)
NULL
> h2o.saveModel(gbm_model_gridperf1, path = tmpdir_model)
[1] "/data/analyticsdb/h2omodels-v1-avg-bitrate/gbm_grid1_model_17"
> h2o.download_pojo(gbm_model_gridperf1, path = tmpdir_model)
[1] "gbm_grid1_model_17.java"
> h2o.download_mojo(gbm_model_gridperf1, path = tmpdir_model)
[1] "gbm_grid1_model_17.zip"
> spark_disconnect(sc)
> 
```

## Compile the H2O model as a part of UDF project

All code for this section can be found in this git repository.  To simplify the build process, I have included a pom.xml file.  For Maven users, this will automatically grab the dependencies you need to compile.

To use the template:

1. Copy the Java from H2O into the project
2. Update the POJO to be part of the UDF package
3. Update the pom.xml to reflect your version of Hadoop and Hive
4. Compile

### Copy the java from H2O into the project

1. Script declared here, for running sample : https://stash.performgroup.com/projects/BDA/repos/bda_exadata_samples/browse/SAMPLE_IXPBDAOPTA01_TOOLS/jpac-sparklyr/rstudio_jobs/AVGBitRate/hive_udf_GBMAVGBITRATE_v1/localjars/download-gateway-jar.sh

```bash
$ #!/usr/bin/env bash
$ scp analyticsdb@ixpbdaopta01.prod.ix.perform.local:~/h2omodels-v1-avg-bitrate/h2o-genmodel.jar .
$ scp analyticsdb@ixpbdaopta01.prod.ix.perform.local:~/h2omodels-v1-avg-bitrate/gbm_grid1_model_17.java .
$ mv  gbm_grid1_model_17.java GBMAvgBitRateMo17.loc1.java
$ sed "s,gbm_grid1_model_17,GBMAvgBitRateMo17,g"  GBMAvgBitRateMo17.loc1.java > GBMAvgBitRateMo17.loc2.java
$ # 
$ sed "s,import,package ai.h2o.hive.udf; import,1" GBMAvgBitRateMo17.loc2.java > GBMAvgBitRateMo17.java
$ #
$ cp GBMAvgBitRateMo17.java ../src/main/java/ai/h2o/hive/udf/GBMAvgBitRateMo17.java
$ rm GBMAvgBitRateMo17.loc*.java 
```

### Update the POJO to Be a Part of the Same Package as the UDF ###

To the top of `GBMAvgBitRateMo17.java`, add:

```Java
package ai.h2o.hive.udf;
```

### Update the pom.xml to Reflect Hadoop and Hive Versions ###

Get your version numbers using:

```bash
$ hadoop version
$ hive --version
```

And plug these into the `<properties>`  section of the `pom.xml` file.  Currently, the configuration is set for pulling the necessary dependencies for Hortonworks.  For other Hadoop distributions, you will also need to update the `<repositories>` section to reflect the respective repositories (a commented-out link to a Cloudera repository is included).

### Compile

> Caution:  This tutorial was written using Maven 3.0.4.  Older 2.x versions of Maven may not work.

```bash
$ mvn compile
$ mvn package
$ mvn -X clean install -Dmaven.test.skip=true
```

As with most Maven builds, the first run will probably seem like it is downloading the entire Internet.  It is just grabbing the needed compile dependencies.  In the end, this process should create the file `target/ScoreData-1.0-SNAPSHOT.jar`.

As a part of the build process, Maven is running a unit test on the code. If you are looking to use this template for your own models, you either need to modify the test to reflect your own data, or run Maven without the test (`mvn package -Dmaven.test.skip=true`).  

## Loading test data in Hive
Now load the same test data set into Hive.  This will allow us to score the data in Hive and verify that the results are the same as what we saw in H2O.

```bash
$ hadoop fs -mkdir -p  hdfs:///user/analyticsdb/H2O/ConvivaData
$ hdfs dfs -copyFromLocal conviva1*.csv hdfs:///user/analyticsdb/H2O/ConvivaData
$ hive
```

Here we mark the table as `EXTERNAL` so that Hive doesn't make a copy of the file needlessly.  We also tell Hive to ignore the first line, since it contains the column names.

```hive
> CREATE EXTERNAL TABLE conviva_avgbitrate (asset STRING, deviceos STRING, country STRING, state STRING, city STRING, asn INT, isp STRING, start_time_unix_time INT,startup_time_ms INT, playing_time_ms INT, buffering_time_ms INT, interrupts INT, startup_error INT, sessiontags STRING, ipaddress STRING, cdn STRING, browser STRING, convivasessionid INT, streamurl STRING, errorlist STRING, percentage_complete FLOAT, average_bitrate_kbps INT ) COMMENT 'H2O.ai sample conviva table' ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE location '/user/analyticsdb/H2O/UDFTest/ConvivaSampleData' tblproperties ("skip.header.line.count"="1");
> ANALYZE TABLE conviva COMPUTE STATISTICS;
```


## Copy the UDF to the cluster and load into Hive
```bash
$ hadoop fs -mkdir -p  hdfs:///user/analyticsdb/H2O/UDFtest/GBMAvgBitRateM17lib
$ hdfs dfs -copyFromLocal localjars/h2o-genmodel.jar                hdfs:///user/analyticsdb/H2O/UDFtest/GBMAvgBitRateM17lib
$ hdfs dfs -copyFromLocal target/ScoreDataUDFGBM17-1.0-SNAPSHOT.jar hdfs:///user/analyticsdb/H2O/UDFtest/GBMAvgBitRateM17lib
$ hive
```
Note that for correct class loading, you will need to load the h2o-model.jar before the ScoredData jar file.

```hive
> ADD JAR hdfs:///user/analyticsdb/H2O/UDFtest/GBMAvgBitRateM17lib/h2o-genmodel.jar;
> ADD JAR hdfs:///user/analyticsdb/H2O/UDFtest/GBMAvgBitRateM17lib/ScoreDataUDFGBMAVGM17-1.0-SNAPSHOT.jar;
> CREATE TEMPORARY FUNCTION scoredata AS 'ai.h2o.hive.udf.ScoreDataUDFGBMAVGM17';
> USE staged_akamai;
> SHOW TABLES;
> DROP TABLE IF EXISTS conviva_avgbitrate;
> CREATE TABLE conviva_avgbitrate AS SELECT asset, deviceos, country, state, city, asn as asn, isp, starttimeunixtime as start_time_unix_time, startuptimems as startup_time_ms, playingtimems as playing_time_ms, bufferingtimems as buffering_time_ms, interrupts as interrupts, startuperror as startup_error, sessiontags, ipaddress, cdn, browser, convivasessionid, streamurl, errorlist, percentagecomplete as percentage_complete
> FROM staged_akamai.conviva_logs LIMIT 8000;
> DROP TABLE IF EXISTS conviva_avgbitrate_pred;
> CREATE TABLE conviva_avgbitrate_pred AS SELECT asset, deviceos, country, state, city, isp, sessiontags, ipaddress, cdn, browser, convivasessionid, streamurl, errorlist, percentagecomplete, asn, start_time_unix_time, startup_time_ms, playing_time_ms, buffering_time_ms,startup_error,percentage_complete, scoredata(asn, start_time_unix_time, startup_time_ms, playing_time_ms, buffering_time_ms,startup_error,percentage_complete) 
> FROM staged_akamai.conviva_logs LIMIT 5000;
```

Keep in mind that your UDF is only loaded in Hive for as long as you are using it.  If you `quit;` and then join Hive again, you will have to re-enter the last three lines.

## Score with your UDF
Now the moment we've been working towards:

```r
(IX Prod)[analyticsdb@ixpbdaopta01 ~/testgateway/hive_test]$ cat hive_udf_scoredata_AvgBitRate_ScoreDataUDFGBM17_view.hql 
ADD JAR hdfs:///user/analyticsdb/H2O/UDFtest/GBMAvgBitRateM17lib/h2o-genmodel.jar;
ADD JAR hdfs:///user/analyticsdb/H2O/UDFtest/GBMAvgBitRateM17lib/ScoreDataUDFGBMAVGM17-1.0-SNAPSHOT.jar;
CREATE TEMPORARY FUNCTION scoredatavg AS 'ai.h2o.hive.udf.ScoreDataUDFGBMAVGM17';
USE default;
SHOW TABLES;
DROP TABLE IF EXISTS conviva_avgbitrate_pred;
SELECT asset, deviceos, country, state, city, asn, isp, start_time_unix_time,startup_time_ms, playing_time_ms, buffering_time_ms, interrupts, startup_error, sessiontags, ipaddress, cdn, browser, convivasessionid, streamurl, errorlist, percentage_complete, average_bitrate_kbps,
(IX Prod)[analyticsdb@ixpbdaopta01 ~/testgateway/hive_test]$ bash -x beeline_hive_2.sh password_file2.txt hive_udf_scoredata_AvgBitRate_ScoreDataUDFGBM17_view.hql  
+ echo '<<beeline -f>>  PASSWORDFILE EXECUTIONFILE '
<<beeline -f>>  PASSWORDFILE EXECUTIONFILE 
++ pwd
+ PASSWORDFILE=/home/analyticsdb/testgateway/hive_test/password_file2.txt
++ pwd
+ EXECUTIONFILE=/home/analyticsdb/testgateway/hive_test/hive_udf_scoredata_AvgBitRate_ScoreDataUDFGBM17_view.hql
+ USERNAME1=mediaetlgam
+ echo ' |||| ----- EXECUTION PRINTED WITH CONNECTION SCTRING ----- |||| '
 |||| ----- EXECUTION PRINTED WITH CONNECTION SCTRING ----- |||| 
+ IFS=
+ read -r line
+ LOCAL_PASSWORD=iczHlg7b02YQAuX1
++ echo ' !connect jdbc:hive2://ixpbda04:10000/;user=mediaetlgam;password=iczHlg7b02YQAuX1;principal=hive/ixpbda04.prod.ix.perform.local@BDA.PERFORMGROUP.COM ;'
+ LOCAL_CONNECT=' !connect jdbc:hive2://ixpbda04:10000/;user=mediaetlgam;password=iczHlg7b02YQAuX1;principal=hive/ixpbda04.prod.ix.perform.local@BDA.PERFORMGROUP.COM ;'
+ sed -i '1i  !connect jdbc:hive2://ixpbda04:10000/;user=mediaetlgam;password=iczHlg7b02YQAuX1;principal=hive/ixpbda04.prod.ix.perform.local@BDA.PERFORMGROUP.COM ;' /home/analyticsdb/testgateway/hive_test/hive_udf_scoredata_AvgBitRate_ScoreDataUDFGBM17_view.hql
+ beeline -f /home/analyticsdb/testgateway/hive_test/hive_udf_scoredata_AvgBitRate_ScoreDataUDFGBM17_view.hql
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=512M; support was removed in 8.0
2018-06-04 21:35:29,749 WARN  [main] mapreduce.TableMapReduceUtil: The hbase-prefix-tree module jar containing PrefixTreeCodec is not present.  Continuing without it.
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=512M; support was removed in 8.0
beeline> !connect jdbc:hive2://ixpbda04:10000/;user=mediaetlgam;password=iczHlg7b02YQAuX1;principal=hive/ixpbda04.prod.ix.perform.local@BDA.PERFORMGROUP.COM ;
scan complete in 1ms
Connecting to jdbc:hive2://ixpbda04:10000/;user=mediaetlgam;password=iczHlg7b02YQAuX1;principal=hive/ixpbda04.prod.ix.perform.local@BDA.PERFORMGROUP.COM
Connected to: Apache Hive (version 1.1.0-cdh5.9.0)
Driver: Hive JDBC (version 1.1.0-cdh5.9.0)
Transaction isolation: TRANSACTION_REPEATABLE_READ
0: jdbc:hive2://ixpbda04:10000/> ADD JAR hdfs:///user/analyticsdb/H2O/UDFtest/GBMAvgBitRateM17lib/h2o-genmodel.jar;
INFO  : converting to local hdfs:///user/analyticsdb/H2O/UDFtest/GBMAvgBitRateM17lib/h2o-genmodel.jar
INFO  : Added [/tmp/352e48f2-116b-4cd4-8baa-859fb64bcc48_resources/h2o-genmodel.jar] to class path
INFO  : Added resources: [hdfs:///user/analyticsdb/H2O/UDFtest/GBMAvgBitRateM17lib/h2o-genmodel.jar]
No rows affected (0.184 seconds)
0: jdbc:hive2://ixpbda04:10000/> ADD JAR hdfs:///user/analyticsdb/H2O/UDFtest/GBMAvgBitRateM17lib/ScoreDataUDFGBMAVGM17-1.0-SNAPSHOT.jar;
INFO  : converting to local hdfs:///user/analyticsdb/H2O/UDFtest/GBMAvgBitRateM17lib/ScoreDataUDFGBMAVGM17-1.0-SNAPSHOT.jar
INFO  : Added [/tmp/352e48f2-116b-4cd4-8baa-859fb64bcc48_resources/ScoreDataUDFGBMAVGM17-1.0-SNAPSHOT.jar] to class path
INFO  : Added resources: [hdfs:///user/analyticsdb/H2O/UDFtest/GBMAvgBitRateM17lib/ScoreDataUDFGBMAVGM17-1.0-SNAPSHOT.jar]
No rows affected (0.023 seconds)
0: jdbc:hive2://ixpbda04:10000/> CREATE TEMPORARY FUNCTION scoredatavg AS 'ai.h2o.hive.udf.ScoreDataUDFGBMAVGM17';
INFO  : Compiling command(queryId=hive_20180604213535_6a041b86-00d8-4013-aff5-ad7fa54c409c): CREATE TEMPORARY FUNCTION scoredatavg AS 'ai.h2o.hive.udf.ScoreDataUDFGBMAVGM17'
INFO  : Semantic Analysis Completed
INFO  : Returning Hive schema: Schema(fieldSchemas:null, properties:null)
INFO  : Completed compiling command(queryId=hive_20180604213535_6a041b86-00d8-4013-aff5-ad7fa54c409c); Time taken: 0.015 seconds
INFO  : Executing command(queryId=hive_20180604213535_6a041b86-00d8-4013-aff5-ad7fa54c409c): CREATE TEMPORARY FUNCTION scoredatavg AS 'ai.h2o.hive.udf.ScoreDataUDFGBMAVGM17'
INFO  : Starting task [Stage-0:FUNC] in serial mode
INFO  : Completed executing command(queryId=hive_20180604213535_6a041b86-00d8-4013-aff5-ad7fa54c409c); Time taken: 0.023 seconds
INFO  : OK
No rows affected (0.059 seconds)
0: jdbc:hive2://ixpbda04:10000/> USE default;
INFO  : Compiling command(queryId=hive_20180604213535_b47d993a-1337-457d-9936-27504c32d2e6): USE default
INFO  : Semantic Analysis Completed
INFO  : Returning Hive schema: Schema(fieldSchemas:null, properties:null)
INFO  : Completed compiling command(queryId=hive_20180604213535_b47d993a-1337-457d-9936-27504c32d2e6); Time taken: 0.013 seconds
INFO  : Executing command(queryId=hive_20180604213535_b47d993a-1337-457d-9936-27504c32d2e6): USE default
INFO  : Starting task [Stage-0:DDL] in serial mode
INFO  : Completed executing command(queryId=hive_20180604213535_b47d993a-1337-457d-9936-27504c32d2e6); Time taken: 0.01 seconds
INFO  : OK
No rows affected (0.032 seconds)
0: jdbc:hive2://ixpbda04:10000/> SHOW TABLES;
INFO  : Compiling command(queryId=hive_20180604213535_c842b19a-a9f8-40ab-915e-9382ad99c07a): SHOW TABLES
INFO  : Semantic Analysis Completed
INFO  : Returning Hive schema: Schema(fieldSchemas:[FieldSchema(name:tab_name, type:string, comment:from deserializer)], properties:null)
INFO  : Completed compiling command(queryId=hive_20180604213535_c842b19a-a9f8-40ab-915e-9382ad99c07a); Time taken: 0.003 seconds
INFO  : Executing command(queryId=hive_20180604213535_c842b19a-a9f8-40ab-915e-9382ad99c07a): SHOW TABLES
INFO  : Starting task [Stage-0:DDL] in serial mode
INFO  : Completed executing command(queryId=hive_20180604213535_c842b19a-a9f8-40ab-915e-9382ad99c07a); Time taken: 0.008 seconds
INFO  : OK
+--------------------------+--+
|         tab_name         |
+--------------------------+--+
| airports                 |
| categories               |
| conviva_avgbitrate       |
| newonehundredcolstables  |
| conviva                 |
| conviva_pred            |
| test_qa                  |
+--------------------------+--+
7 rows selected (0.088 seconds)
0: jdbc:hive2://ixpbda04:10000/> DROP TABLE IF EXISTS conviva_avgbitrate_pred;
INFO  : Compiling command(queryId=hive_20180604213535_ac2d627b-c9a7-49fd-9fe3-2fcee34d818a): DROP TABLE IF EXISTS conviva_avgbitrate_pred
INFO  : Semantic Analysis Completed
INFO  : Returning Hive schema: Schema(fieldSchemas:null, properties:null)
INFO  : Completed compiling command(queryId=hive_20180604213535_ac2d627b-c9a7-49fd-9fe3-2fcee34d818a); Time taken: 0.004 seconds
INFO  : Executing command(queryId=hive_20180604213535_ac2d627b-c9a7-49fd-9fe3-2fcee34d818a): DROP TABLE IF EXISTS conviva_avgbitrate_pred
INFO  : Starting task [Stage-0:DDL] in serial mode
INFO  : Completed executing command(queryId=hive_20180604213535_ac2d627b-c9a7-49fd-9fe3-2fcee34d818a); Time taken: 0.006 seconds
INFO  : OK
No rows affected (0.017 seconds)
0: jdbc:hive2://ixpbda04:10000/> SELECT asset, deviceos, country, state, city, asn, isp, start_time_unix_time,startup_time_ms, playing_time_ms, buffering_time_ms, interrupts, startup_error, sessiontags, ipaddress, cdn, browser, convivasessionid, streamurl, errorlist, percentage_complete, average_bitrate_kbps,
. . . . . . . . . . . . . . . .>  scoredatavg(asn, start_time_unix_time, startup_time_ms, playing_time_ms, buffering_time_ms, interrupts, startup_error, percentage_complete) 
. . . . . . . . . . . . . . . .>  as predict_average_bitrate_kbps FROM conviva_avgbitrate LIMIT 20;
INFO  : Compiling command(queryId=hive_20180604213535_a936f79c-836c-4189-baaa-c83ea07e7ae6): SELECT asset, deviceos, country, state, city, asn, isp, start_time_unix_time,startup_time_ms, playing_time_ms, buffering_time_ms, interrupts, startup_error, sessiontags, ipaddress, cdn, browser, convivasessionid, streamurl, errorlist, percentage_complete, average_bitrate_kbps,
 scoredatavg(asn, start_time_unix_time, startup_time_ms, playing_time_ms, buffering_time_ms, interrupts, startup_error, percentage_complete) 
 as predict_average_bitrate_kbps FROM conviva_avgbitrate LIMIT 20
INFO  : Semantic Analysis Completed
INFO  : Returning Hive schema: Schema(fieldSchemas:[FieldSchema(name:asset, type:string, comment:null), FieldSchema(name:deviceos, type:string, comment:null), FieldSchema(name:country, type:string, comment:null), FieldSchema(name:state, type:string, comment:null), FieldSchema(name:city, type:string, comment:null), FieldSchema(name:asn, type:int, comment:null), FieldSchema(name:isp, type:string, comment:null), FieldSchema(name:start_time_unix_time, type:int, comment:null), FieldSchema(name:startup_time_ms, type:int, comment:null), FieldSchema(name:playing_time_ms, type:int, comment:null), FieldSchema(name:buffering_time_ms, type:bigint, comment:null), FieldSchema(name:interrupts, type:bigint, comment:null), FieldSchema(name:startup_error, type:bigint, comment:null), FieldSchema(name:sessiontags, type:boolean, comment:null), FieldSchema(name:ipaddress, type:string, comment:null), FieldSchema(name:cdn, type:string, comment:null), FieldSchema(name:browser, type:string, comment:null), FieldSchema(name:convivasessionid, type:string, comment:null), FieldSchema(name:streamurl, type:string, comment:null), FieldSchema(name:errorlist, type:string, comment:null), FieldSchema(name:percentage_complete, type:bigint, comment:null), FieldSchema(name:average_bitrate_kbps, type:int, comment:null), FieldSchema(name:predict_average_bitrate_kbps, type:double, comment:null)], properties:null)
INFO  : Completed compiling command(queryId=hive_20180604213535_a936f79c-836c-4189-baaa-c83ea07e7ae6); Time taken: 0.08 seconds
INFO  : Executing command(queryId=hive_20180604213535_a936f79c-836c-4189-baaa-c83ea07e7ae6): SELECT asset, deviceos, country, state, city, asn, isp, start_time_unix_time,startup_time_ms, playing_time_ms, buffering_time_ms, interrupts, startup_error, sessiontags, ipaddress, cdn, browser, convivasessionid, streamurl, errorlist, percentage_complete, average_bitrate_kbps,
 scoredatavg(asn, start_time_unix_time, startup_time_ms, playing_time_ms, buffering_time_ms, interrupts, startup_error, percentage_complete) 
 as predict_average_bitrate_kbps FROM conviva_avgbitrate LIMIT 20
INFO  : Query ID = hive_20180604213535_a936f79c-836c-4189-baaa-c83ea07e7ae6
INFO  : Total jobs = 1
INFO  : Launching Job 1 out of 1
INFO  : Starting task [Stage-1:MAPRED] in serial mode
INFO  : In order to change the average load for a reducer (in bytes):
INFO  :   set hive.exec.reducers.bytes.per.reducer=<number>
INFO  : In order to limit the maximum number of reducers:
INFO  :   set hive.exec.reducers.max=<number>
INFO  : In order to set a constant number of reducers:
INFO  :   set mapreduce.job.reduces=<number>
INFO  : Starting Spark Job = 26c12f61-33e1-43af-b3b7-ebe0f6edc3aa
INFO  : Running with YARN Application = application_1526337713070_2347
INFO  : Kill Command = /opt/cloudera/parcels/CDH-5.9.0-1.cdh5.9.0.p0.21/lib/hadoop/bin/yarn application -kill application_1526337713070_2347
INFO  : 
Query Hive on Spark job[0] stages:
INFO  : 0
INFO  : 
Status: Running (Hive on Spark job[0])
INFO  : Job Progress Format
CurrentTime StageId_StageAttemptId: SucceededTasksCount(+RunningTasksCount-FailedTasksCount)/TotalTasksCount [StageCost]
INFO  : 2018-06-04 21:35:55,498	Stage-0_0: 0(+1)/1	
INFO  : 2018-06-04 21:35:58,508	Stage-0_0: 0(+1)/1	
INFO  : 2018-06-04 21:36:00,514	Stage-0_0: 1/1 Finished	
INFO  : Status: Finished successfully in 16.05 seconds
INFO  : =====Spark Job[26c12f61-33e1-43af-b3b7-ebe0f6edc3aa] statistics=====
INFO  : HIVE
INFO  : 	CREATED_FILES: 1
INFO  : 	DESERIALIZE_ERRORS: 0
INFO  : 	RECORDS_IN: 24
INFO  : 	RECORDS_OUT_0: 20
INFO  : Spark Job[26c12f61-33e1-43af-b3b7-ebe0f6edc3aa] Metrics
INFO  : 	ExecutorDeserializeTime: 2183
INFO  : 	ExecutorRunTime: 2597
INFO  : 	ResultSize: 2118
INFO  : 	JvmGCTime: 564
INFO  : 	ResultSerializationTime: 2
INFO  : 	MemoryBytesSpilled: 0
INFO  : 	DiskBytesSpilled: 0
INFO  : 	BytesRead: 73473
INFO  : Execution completed successfully
INFO  : Completed executing command(queryId=hive_20180604213535_a936f79c-836c-4189-baaa-c83ea07e7ae6); Time taken: 28.382 seconds
INFO  : OK
+----------------------------------------------------+----------------+----------+------------+----------------+--------+-----------+-----------------------+------------------+------------------+--------------------+-------------+----------------+--------------+------------------+---------+----------+----------------------------------------------------+----------------------------------------------------+------------+----------------------+-----------------------+-------------------------------+--+
|                       asset                        |    deviceos    | country  |   state    |      city      |  asn   |    isp    | start_time_unix_time  | startup_time_ms  | playing_time_ms  | buffering_time_ms  | interrupts  | startup_error  | sessiontags  |    ipaddress     |   cdn   | browser  |                  convivasessionid                  |                     streamurl                      | errorlist  | percentage_complete  | average_bitrate_kbps  | predict_average_bitrate_kbps  |
+----------------------------------------------------+----------------+----------+------------+----------------+--------+-----------+-----------------------+------------------+------------------+--------------------+-------------+----------------+--------------+------------------+---------+----------+----------------------------------------------------+----------------------------------------------------+------------+----------------------+-----------------------+-------------------------------+--+
| [1dq41bd1bbfiv1mk6d9x75o0jm] 鳥栖 vs 広島：第3節          | amazon-fireos  | japan    | hiroshima  | hiroshima-shi  | 4725   | Softbank  | 1489211536            | 10343            | 47086            | 0                  | 0           | 0              | NULL         | 61.116.247.37    | LEVEL3  | Chrome   | 8403:3589720432:609327124:1236359423:1422259661    | https://dc1-live2dash-perform.secure.footprint.net/out/u/encr_7280130756_b7f8d6c401a941a9a5ff5b17387330f3.mpd?c3.ri=1256939642364540641 |            | -1                   | 1379                  | 1379.4016462667228            |
| [3b3semi1347t1mslmbtsc4zha] オープン戦：ベイスターズ vs マリーンズ  | amazon-fireos  | japan    | hiroshima  | hiroshima-shi  | 4725   | Softbank  | 1489207981            | 14675            | 2058             | 0                  | 0           | 0              | NULL         | 61.116.247.37    | AKAMAI  | Chrome   | 8403:3589720432:609327124:1236359423:3495202938    | https://dc2live2jpdazn-a.akamaihd.net/out/u/encr_7128066916_9ca64fbf4e63474cbedd0f31721e7c1a.mpd?c3.ri=1256939642364446700 |            | -1                   | 672                   | 671.7323096936875             |
| [1dq41bd1bbfiv1mk6d9x75o0jm] 鳥栖 vs 広島：第3節          | amazon-fireos  | japan    | hiroshima  | hiroshima-shi  | 4725   | Softbank  | 1489211628            | 10379            | 7431711          | 2346               | 1           | 0              | NULL         | 61.116.247.37    | LEVEL3  | Chrome   | 8403:3589720432:609327124:1236359423:3502197652    | https://dc2-live2dash-perform.secure.footprint.net/out/u/encr_7280642583_5bc1cde2f8954022860db7829ce37926.mpd?c3.ri=1256939642364546095 |            | -1                   | 1379                  | 1378.9893766930895            |
| [3b3semi1347t1mslmbtsc4zha] オープン戦：ベイスターズ vs マリーンズ  | amazon-fireos  | japan    | hiroshima  | hiroshima-shi  | 4725   | Softbank  | 1489211608            | 11915            | 3024             | 0                  | 0           | 0              | NULL         | 61.116.247.37    | AKAMAI  | Chrome   | 8403:3589720432:609327124:1236359423:4250895081    | https://dc1live2jpdazn-a.akamaihd.net/out/u/encr_7133698726_419e3eb62b13481fb2d144f466fe00a2.mpd?c3.ri=1256939642364545109 |            | -1                   | 1379                  | 1378.5837063945678            |
| [1lk5etpk19woc1mteevfzufr6w] G大阪 vs FC東京：第3節       | AND            | japan    | tokyo      | tokyo          | 4713   | NTT       | 1489231553            | 3436             | 39935            | 0                  | 0           | 0              | NULL         | 153.166.192.223  | AKAMAI  | Chrome   | 21063:875596950:3659848776:3527955680:1626252005   | https://dc2live2jpdazn-a.akamaihd.net/out/u/encr_7280642586_5ed3fc06437540638f9e37e2ac89e448.mpd?c3.ri=1256939949286534651 |            | -1                   | 1173                  | 933.0130793523663             |
| [p0z8a8xl1cqi16xy27v1utmme] 仙台 vs 神戸：第3節           | AND            | japan    | tokyo      | tokyo          | 4713   | NTT       | 1489223326            | 3516             | 12316            | 0                  | 0           | 0              | NULL         | 153.166.192.223  | AKAMAI  | Chrome   | 21063:875596950:3659848776:3527955680:2606665007   | https://dc1livejpdazn-a.akamaihd.net/out/u/encr_7321602693_059e33945dda4efe9494b18b1a57cc47.mpd?c3.ri=1257221424258905178 |            | -1                   | 672                   | 4457.6422141752355            |
| [srbg61r9m5h8129wtcrhnz2ul] 仙台 vs 神戸：第3節           | WIN            | japan    | tokyo      | tokyo          | 17676  | Softbank  | 1489221405            | 2992             | 1894304          | 2726               | 1           | 0              | NULL         | 126.161.129.215  | LEVEL3  | MSIE     | 29518:3333681720:2965373282:3756644126:45922441    | https://dc2-livemss-perform.secure.footprint.net/out/u/encr_7321090817_fb532eaec5334263a3bb22a566b29b4e.ism/Manifest?c3.ri=1257221424258863285 |            | -1                   | 4670                  | 4669.615860462471             |
| [qiij8u4ka6mz1uyjy84cp0kk6] 新潟 vs 清水：第3節           | WIN            | japan    | tokyo      | tokyo          | 17676  | Softbank  | 1489217419            | 2248             | 19966            | 0                  | 0           | 0              | NULL         | 126.161.129.215  | AKAMAI  | MSIE     | 29518:3333681720:2965373282:3756644126:244364516   | https://dc1live2jpdazn-a.akamaihd.net/out/u/encr_7280642581_23e2f35291b64ba4a5a785dfa0819003.ism/Manifest?c3.ri=1257221424258693987 |            | -1                   | 3774                  | 3773.5931919566924            |
| [1mza5xfcomy4g1ugo34rnzwtbb] 新潟 vs 清水：第3節          | WIN            | japan    | tokyo      | tokyo          | 17676  | Softbank  | 1489217641            | 2743             | 3755948          | 5255               | 1           | 0              | NULL         | 126.161.129.215  | AKAMAI  | MSIE     | 29518:3333681720:2965373282:3756644126:393946389   | https://dc1live2jpdazn-a.akamaihd.net/out/u/encr_7280642581_23e2f35291b64ba4a5a785dfa0819003.ism/Manifest?c3.ri=1257221424258703614 |            | -1                   | 4272                  | 4272.224334568686             |
| [1qsc2kp9x099v1tg2qizlilxqp] 千葉 vs 名古屋：第3節         | WIN            | japan    | tokyo      | tokyo          | 17676  | Softbank  | 1489210203            | 2951             | 3454353          | 0                  | 0           | 0              | NULL         | 126.161.129.215  | AKAMAI  | MSIE     | 29518:3333681720:2965373282:3756644126:403305875   | https://dc1live2jpdazn-a.akamaihd.net/out/u/encr_7280642605_fd617132ea094f8d842a18f136a45a0f.ism/Manifest?c3.ri=1256939642364501086 |            | -1                   | 5567                  | 5667.557221277957             |
| [18fuhz9mv3cpq1pycwd4qvudkz] 札幌 vs C大阪：第3節         | WIN            | japan    | tokyo      | tokyo          | 17676  | Softbank  | 1489217349            | 2084             | 67560            | 0                  | 0           | 0              | NULL         | 126.161.129.215  | AKAMAI  | MSIE     | 29518:3333681720:2965373282:3756644126:1133969725  | https://dc2livejpdazn-a.akamaihd.net/out/u/encr_7280130752_27aced7804e247c19ac6a3163e37f492.ism/Manifest?c3.ri=1257221424258690237 |            | -1                   | 2371                  | 3700.18800151348              |
| [1qsc2kp9x099v1tg2qizlilxqp] 千葉 vs 名古屋：第3節         | WIN            | japan    | tokyo      | tokyo          | 17676  | Softbank  | 1489209312            | 2862             | 435636           | 1022               | 1           | 0              | NULL         | 126.161.129.215  | AKAMAI  | MSIE     | 29518:3333681720:2965373282:3756644126:1615067305  | https://dc2live2jpdazn-a.akamaihd.net/out/u/encr_7280642606_f1411bd4336043d58e827e5a51e093df.ism/Manifest?c3.ri=1257221117012988881 |            | -1                   | 3550                  | 7657.578627499161             |
| [18fuhz9mv3cpq1pycwd4qvudkz] 札幌 vs C大阪：第3節         | WIN            | japan    | tokyo      | tokyo          | 17676  | Softbank  | 1489217441            | 2543             | 169859           | 7531               | 2           | 0              | NULL         | 126.161.129.215  | LEVEL3  | MSIE     | 29518:3333681720:2965373282:3756644126:2274929457  | https://dc1-livemss-perform.secure.footprint.net/out/u/encr_7280130751_b0fab6e983d146678887b56b68c37385.ism/Manifest?c3.ri=1256939949286178593 |            | -1                   | 4868                  | 4867.662397517879             |
| [3b3semi1347t1mslmbtsc4zha] オープン戦：ベイスターズ vs マリーンズ  | WIN            | japan    | tokyo      | tokyo          | 17676  | Softbank  | 1489209292            | 11332            | 5363             | 0                  | 0           | 0              | NULL         | 126.161.129.215  | AKAMAI  | MSIE     | 29518:3333681720:2965373282:3756644126:2955525421  | https://dc1live2jpdazn-a.akamaihd.net/out/u/encr_7133698726_73ea7f841eed4d318878965bf1a0955b.ism/Manifest?c3.ri=1256939642364481967 |            | -1                   | 835                   | 835.570897440592              |
| [qiij8u4ka6mz1uyjy84cp0kk6] 新潟 vs 清水：第3節           | WIN            | japan    | tokyo      | tokyo          | 17676  | Softbank  | 1489213660            | 4581             | 3327831          | 3604               | 2           | 0              | NULL         | 126.161.129.215  | LEVEL3  | MSIE     | 29518:3333681720:2965373282:3756644126:2973736774  | https://dc2-live2mss-perform.secure.footprint.net/out/u/encr_7280130757_5a63eb9f5b2a4cccba8df9b500be5d8e.ism/Manifest?c3.ri=1256939949285991374 |            | -1                   | 5898                  | 5898.023158478287             |
| [pd5swu011q5o1nf9pr2o6jd9b] 大宮 vs 磐田：第3節           | WIN            | japan    | tokyo      | tokyo          | 17676  | Softbank  | 1489217015            | 2738             | 350759           | 0                  | 0           | 0              | NULL         | 126.161.129.215  | AKAMAI  | MSIE     | 29518:3333681720:2965373282:3756644126:3308715894  | https://dc2livejpdazn-a.akamaihd.net/out/u/encr_7280130754_5a9b767534b04d73ba43000fa79ee478.ism/Manifest?c3.ri=1256939949286156695 |            | -1                   | 3838                  | 3838.627588076399             |
| [x0mitid6rufj1ci9ytyrz302b] レバークーゼン vs ブレーメン：第24節  | WIN            | japan    | tokyo      | tokyo          | 2518   |           | 1489201961            | 3540             | 1240663          | 5627               | 3           | 0              | NULL         | 119.243.194.100  | AKAMAI  | Edge     | 45385:1700676271:3478145667:2470881220:76701811    | https://dc2live2jpdazn-a.akamaihd.net/out/u/encr_7128066901_fe099fb6dcc94256bd48291d68e85613.ism/Manifest?c3.ri=1256939642364376752 |            | 17                   | 6973                  | 6166.312645786062             |
| [1c1u3jcah2byx1e74gptj52drr] ファイナル3第1戦：女子・男子       | WIN            | japan    | tokyo      | tokyo          | 2518   |           | 1489210954            | 4579             | 25781            | 0                  | 0           | 0              | NULL         | 119.243.194.100  | AKAMAI  | Edge     | 45385:1700676271:3478145667:2470881220:185353000   | https://dc2livejpdazn-a.akamaihd.net/out/u/encr_7280642594_8fe68bb87a064b7c858b190e3cc61276.ism/Manifest?c3.ri=1257221117013024399 |            | -1                   | 7000                  | -1053.300513209198            |
| [1c1u3jcah2byx1e74gptj52drr] ファイナル3第1戦：女子・男子       | WIN            | japan    | tokyo      | tokyo          | 2518   |           | 1489211248            | 2872             | 7121             | 0                  | 0           | 0              | NULL         | 119.243.194.100  | AKAMAI  | Edge     | 45385:1700676271:3478145667:2470881220:877397389   | https://dc2livejpdazn-a.akamaihd.net/out/u/encr_7280642594_8fe68bb87a064b7c858b190e3cc61276.ism/Manifest?c3.ri=1256939642364526175 |            | -1                   | 7000                  | 365.43157449316686            |
| [mid8c3hffr681i0wxn0gj5pc9] V・チャレンジマッチ第1戦：女子・男子    | WIN            | japan    | tokyo      | tokyo          | 2518   |           | 1489213275            | 3000             | 3131             | 0                  | 0           | 0              | NULL         | 119.243.194.100  | AKAMAI  | Edge     | 45385:1700676271:3478145667:2470881220:1190049994  | https://dc2live2jpdazn-a.akamaihd.net/out/u/encr_7280642593_62e2c6c386a04056a5fab4e0b29cda2b.ism/Manifest?c3.ri=1257221424258488757 |            | -1                   | 6093                  | 2994.2818358293594            |
+----------------------------------------------------+----------------+----------+------------+----------------+--------+-----------+-----------------------+------------------+------------------+--------------------+-------------+----------------+--------------+------------------+---------+----------+----------------------------------------------------+----------------------------------------------------+------------+----------------------+-----------------------+-------------------------------+--+
20 rows selected (28.566 seconds)
0: jdbc:hive2://ixpbda04:10000/> 
0: jdbc:hive2://ixpbda04:10000/> 
Closing: 0: jdbc:hive2://ixpbda04:10000/;
```


<a name="Limitations"></a>
## Limitations

This solution is fairly quick and easy to implement.  Once you've run through things once, going through steps 1-5 should be pretty painless.  There are, however, a few things to be desired here.

The major trade-off made in this template has been a more generic design over strong input checking.   To be applicable for any POJO, the code only checks that the user-supplied arguments have the correct count and they are all at least primitive types.  Stronger type checking could be done by generating Hive UDF code on a per-model basis.

Also, while the template isn't specific to any given model, it isn't completely flexible to the incoming data either.  If you used 12 of 19 fields as predictors (as in this example), then you must feed the scoredata() UDF only those 12 fields, and in the order that the POJO expects. This is fine for a small number of predictors, but can be messy for larger numbers of predictors.  Ideally, it would be nicer to say `SELECT scoredata(*) FROM conviva ;` and let the UDF pick out the relevant fields by name.  While the H2O POJO does have utility functions for this, Hive, on the other hand, doesn't provide UDF writers the names of the fields (as mentioned in [this](https://issues.apache.org/jira/browse/HIVE-3491) Hive feature request) from which the arguments originate.

Finally, as written, the UDF only returns a single prediction value.  The H2O POJO actually returns an array of float values.  The first value is the main prediction and the remaining values hold probability distributions for classifiers.  This code can easily be expanded to return all values if desired.

## A Look at the UDF Template

The template code starts with some basic annotations that define the nature of the UDF and display some simple help output when the user types `DESCRIBE scoredata` or `DESCRIBE EXTENDED scoredata`.
