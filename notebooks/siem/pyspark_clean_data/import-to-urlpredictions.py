from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession, HiveContext

SparkContext.setSystemProperty("hive.metastore.uris", "thrift://chpbda04.prod.ch.perform.local:9083")

sparkSession = (SparkSession
                .builder
                .appName('ImportData-urltopredict-SIEM')
                .enableHiveSupport()
                .getOrCreate())

process_date='20181116'
input_file="hdfs:///user/siemanalyst/data/staged/urltopredict/dt="+process_date
#
#
url_toprd_df= sparkSession.read.json(input_file)
url_toprd_df.printSchema()
url_toprd_df.registerTempTable("urltopredict")

# HiveQL Scoring table Load
sql_publish = "INSERT INTO TABLE siem.url_mdl_score_predict PARTITION (dt="+process_date+")"+\
" SELECT CAST(urltopredict.url AS STRING) AS url, CAST(urltopredict.ynverified  AS INT) AS ynverified , CAST(urltopredict.url_length  AS INT) AS url_length, CAST(urltopredict.massiveurl  AS INT) AS massiveurl ,CAST(urltopredict.count_at  AS INT) AS count_at ,CAST(urltopredict.count_dot  AS INT) AS count_dot, CAST(urltopredict.url_is_ip  AS INT) AS url_is_ip, CAST(urltopredict.count_dot_com  AS INT) AS count_dot_com, CAST(urltopredict.url_kl_en AS DOUBLE) AS url_kl_en, CAST(urltopredict.url_bad_kl_en AS INT) AS url_bad_kl_en ,CAST(urltopredict.url_ks_en AS DOUBLE) AS url_ks_en ,CAST(urltopredict.url_bad_ks_en AS INT) AS url_bad_ks_en, scoredatav2(url_length,massiveurl,count_at,count_dot,url_is_ip,count_dot_com,url_kl_en,url_bad_kl_en,url_ks_en,url_bad_ks_en) as mdl_score_phishing FROM urltopredict"

#scoredatav2(CAST(urltopredict.url_length  AS INT),CAST(urltopredict.massiveurl  AS INT) AS massiveurl,CAST(urltopredict.count_at  AS INT) AS count_at ,CAST(urltopredict.count_dot  AS INT) AS count_dot, CAST(urltopredict.url_is_ip  AS INT) AS url_is_ip, CAST(urltopredict.count_dot_com  AS INT) AS count_dot_com, CAST(urltopredict.url_kl_en AS DOUBLE) AS url_kl_en, CAST(urltopredict.url_bad_kl_en AS INT) AS url_bad_kl_en ,CAST(urltopredict.url_ks_en AS DOUBLE) AS url_ks_en ,CAST(urltopredict.url_bad_ks_en AS INT) as mdl_score_phishing 

# scoredatav2 requires: [url_length, massiveurl, count_at, count_dot, url_is_ip, count_dot_com, url_kl_en, url_bad_kl_en, url_ks_en, url_bad_ks_en, ynverified]


# Add Scoring H20AUTOML into HiveContext 
sparkSession.sql("ADD JAR hdfs:////user/siemanalyst/predictor/udf/StackedEnsemble_AllModels_AutoML/h2o-genmodel.jar")
sparkSession.sql("ADD JAR hdfs:///user/siemanalyst/predictor/udf/StackedEnsemble_AllModels_AutoML/ScoreDataUDFAUTOML-2.0-SNAPSHOT.jar")
sparkSession.sql("CREATE TEMPORARY FUNCTION scoredatav2 AS 'ai.h2o.hive.udf.ScoreDataM2UDF' ")

sparkSession.sql("ALTER TABLE siem.url_mdl_score_predict DROP IF EXISTS PARTITION (dt="+process_date+")")

# Write into Hive
df_load = sparkSession.sql(sql_publish)

sparkSession.stop()
                