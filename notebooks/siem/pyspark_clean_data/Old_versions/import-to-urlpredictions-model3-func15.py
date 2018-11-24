from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession, HiveContext

SparkContext.setSystemProperty("hive.metastore.uris", "thrift://chpbda04.prod.ch.perform.local:9083")

sparkSession = (SparkSession
                .builder
                .appName('ImportData-url_model3_score_predict-SIEM')
                .enableHiveSupport()
                .getOrCreate())

process_date='20181116'
input_file="hdfs:///user/siemanalyst/data/staged/urltopredict/dt="+process_date
#

# SparkSQL read files as temp_table 
sql_read_files ="SELECT CAST(urltopredict_files.url AS STRING) AS url, CAST(urltopredict_files.ynverified  AS INT) AS ynverified , CAST(urltopredict_files.url_length  AS INT) AS url_length, CAST(urltopredict_files.massiveurl  AS INT) AS massiveurl ,CAST(urltopredict_files.count_at  AS INT) AS count_at , CAST(urltopredict_files.count_dot  AS INT) AS count_dot, CAST(urltopredict_files.url_is_ip  AS INT) AS url_is_ip, CAST(urltopredict_files.count_dot_com  AS INT) AS count_dot_com, CAST(urltopredict_files.url_kl_en AS DOUBLE) AS url_kl_en, CAST(urltopredict_files.url_bad_kl_en AS INT) AS url_bad_kl_en, CAST(urltopredict_files.url_ks_en AS DOUBLE) AS url_ks_en, CAST(urltopredict_files.url_bad_ks_en AS INT) AS url_bad_ks_en, CAST(urltopredict_files.url_kl_phish AS DOUBLE) AS url_kl_phish, CAST(urltopredict_files.url_bad_kl_phish AS INT) AS url_bad_kl_phish, \
CAST(urltopredict_files.url_ks_phish AS DOUBLE) AS url_ks_phish, CAST(urltopredict_files.url_bad_ks_phish AS INT) AS url_bad_ks_phish, CAST(urltopredict_files.url_bad_words_domain AS INT) AS url_bad_words_domain FROM urltopredict_files"
# HiveQL Scoring table Load
sql_publish = "INSERT INTO TABLE siem.url_model3_score_predict PARTITION (dt="+process_date+")"+\
" SELECT  url, ynverified, url_length, massiveurl, count_at, count_dot, url_is_ip, count_dot_com, url_kl_en, url_bad_kl_en, url_ks_en, url_bad_ks_en, url_kl_phish, url_bad_kl_phish, url_ks_phish, url_bad_ks_phish, url_bad_words_domain, scoredatav3(url_length, massiveurl, count_at, count_dot, url_is_ip, count_dot_com, url_kl_en, url_bad_kl_en, url_ks_en, url_bad_ks_en, url_kl_phish, url_bad_kl_phish, url_ks_phish, url_bad_ks_phish, url_bad_words_domain) as mdl_score_phishing FROM urltopredict"


# scoredatav3 requires: [url_length, massiveurl, count_at, count_dot, url_is_ip, count_dot_com, url_kl_en, url_bad_kl_en, url_ks_en, url_bad_ks_en, url_kl_phish, url_bad_kl_phish, url_ks_phish, url_bad_ks_phish, url_bad_words_domain, ynverified]

# Add Scoring H20AUTOML into HiveContext 
sparkSession.sql("ADD JAR hdfs:////user/siemanalyst/predictor/udf/StackedEnsemble_AllModels_AutoML/h2o-genmodel.jar")
sparkSession.sql("ADD JAR hdfs:///user/siemanalyst/predictor/udf/StackedEnsemble_AllModels_AutoML/ScoreDataUDFAUTOML-2.0-SNAPSHOT.jar")
sparkSession.sql("CREATE TEMPORARY FUNCTION scoredatav3 AS 'ai.h2o.hive.udf.ScoreDataM3UDF' ")
sparkSession.sql("ALTER TABLE siem.url_model3_score_predict DROP IF EXISTS PARTITION (dt="+process_date+")")

# Spark read Source Files
#
url_toprd_df= sparkSession.read.json(input_file)
url_toprd_df.printSchema()
url_toprd_df.registerTempTable("urltopredict_files")
#
# Read Cast Variables
df_cast_structure=sparkSession.sql(sql_read_files)
df_cast_structure.printSchema()
df_cast_structure.registerTempTable("urltopredict")
#
# Write into Hive
df_load = sparkSession.sql(sql_publish)
#
sparkSession.stop()