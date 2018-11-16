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
url_toprd_df= sparkSession.read.json(inp, header=True)
url_toprd_df.printSchema()
url_toprd_df.registerTempTable("temp_urltopredict")

sql_publish = s"INSERT INTO TABLE siem.urltopredict PARTITION (dt="+process_date+")"+\
" SELECT url, ynverified, url_length, massiveurl, count_at, count_dot, url_is_ip, count_dot_com, url_kl_en, url_bad_kl_en, url_ks_en, url_bad_ks_en FROM temp_urltopredict"

# Write into Hive
df_load = sparkSession.sql(sql_publish)


sparkSession.stop()
                