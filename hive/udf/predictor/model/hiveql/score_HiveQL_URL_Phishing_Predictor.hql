set hive.execution.engine=mr;

SELECT url, ynverified,url_length,massiveurl,count_at,count_dot,url_is_ip,count_dot_com,url_kl_en,url_bad_kl_en,url_ks_en,url_bad_ks_en,
 ynverified as original_phishing_flag ,mdl_score_phishing as predicted_phishing_flag
FROM siem.url_model3_score_predict where url is not null limit 10 ;

SELECT COUNT(DISTINCT url)  from siem.url_model3_score_predict  where url is not null group by url ;

SELECT url, ynverified,url_length,massiveurl,count_at,count_dot,url_is_ip,count_dot_com,url_kl_en,url_bad_kl_en,url_ks_en,url_bad_ks_en,
 ynverified as original_phishing_flag ,mdl_score_phishing as predicted_phishing_flag
FROM siem.url_model3_score_predict where url is not null  limit 80000 ;

DELETE JAR h2o-genmodel.jar;
DELETE JAR ScoreDataUDFAUTOML-3.0-SNAPSHOT.jar;
ADD JAR hdfs:////user/siemanalyst/predictor/udf/StackedEnsemble_AllModels_AutoML/h2o-genmodel.jar;
ADD JAR hdfs:///user/siemanalyst/predictor/udf/StackedEnsemble_AllModels_AutoML/ScoreDataUDFAUTOML-3.0-SNAPSHOT.jar;
DROP TEMPORARY FUNCTION scoredatav1;
DROP TEMPORARY FUNCTION scoredatav2;
CREATE TEMPORARY FUNCTION scoredatav1 AS 'ai.h2o.hive.udf.ScoreDataM1UDF';
CREATE TEMPORARY FUNCTION scoredatav3 AS 'ai.h2o.hive.udf.ScoreDataM3UDF';

SELECT url, ynverified,url_length,massiveurl,count_at,count_dot,url_is_ip,
count_dot_com,url_kl_en,url_bad_kl_en,url_ks_en,url_bad_ks_en
FROM siem.url_model3_score_predict where url is not null limit 10000 ;

SELECT url,scoredatav3(url_length,massiveurl,count_at,count_dot,url_is_ip,count_dot_com,url_kl_en,
url_bad_kl_en,url_ks_en,url_bad_ks_en,url_kl_phish, url_bad_kl_phish, url_ks_phish, url_bad_kl_phish, url_bad_words_domain) score_phishing ,
 mdl_score_phishing as previous_score_spark, ynverified as real_phishing
FROM siem.url_model3_score_predict where url is not null limit 10 ;



/*
ScoreDataM1UDF
Error while compiling statement: FAILED: SemanticException [Error 10015]: line 13:12 Arguments length
mismatch 'url_bad_ks_en': Incorrect number of arguments. scoredata() requires: [url_length, massiveurl, count_at, count_dot, url_is_ip, count_dot_com, url_kl_en, url_bad_kl_en, url_ks_en, url_bad_ks_en, ynverified]
, in the listed order. Received 11 arguments.

DELETE JAR h2o-genmodel.jar;
DELETE JAR ScoreDataUDFAUTOML-1.0-SNAPSHOT.jar;
ADD JAR hdfs:////user/siemanalyst/predictor/udf/StackedEnsemble_AllModels_AutoML/h2o-genmodel.jar;
ADD JAR hdfs:///user/siemanalyst/predictor/udf/StackedEnsemble_AllModels_AutoML/ScoreDataUDFAUTOML-2.0-SNAPSHOT.jar;
DROP TEMPORARY FUNCTION scoredatav1;
DROP TEMPORARY FUNCTION scoredatav2;
CREATE TEMPORARY FUNCTION scoredatav1 AS 'ai.h2o.hive.udf.ScoreDataM1UDF';
CREATE TEMPORARY FUNCTION scoredatav2 AS 'ai.h2o.hive.udf.ScoreDataM2UDF';

SELECT url, ynverified,url_length,massiveurl,count_at,count_dot,url_is_ip,
count_dot_com,url_kl_en,url_bad_kl_en,url_ks_en,url_bad_ks_en
FROM siem.urltopredict where url is not null limit 10000 ;

SELECT url,scoredatav2(url_length,massiveurl,count_at,count_dot,url_is_ip,count_dot_com,url_kl_en,
url_bad_kl_en,url_ks_en,url_bad_ks_en) score_phishing , ynverified
FROM siem.url_mdl_score_predict where url is not null limit 10 ;

ADD JAR hdfs:///user/siemanalyst/predictor/udf/StackedEnsemble_AllModels_AutoML_20181115_150840/h2o-genmodel.jar;
ADD JAR hdfs:///user/siemanalyst/predictor/udf/StackedEnsemble_AllModels_AutoML_20181115_150840/ScoreDataUDFAUTOML-1.0-SNAPSHOT.jar;

DELETE FILE testbeforebreak.py;
ADD FILE hdfs:///user/siemanalyst/python/urllearningcoef.py;
ADD FILE hdfs:///user/siemanalyst/python/testbeforebreak.py;

MSCK REPAIR TABLE siem.maliciousurls;
SELECT * from maliciousurls where domain is not null;
SELECT * from siem.maliciousurls where uri not in(null,'',' ');

SELECT TRANSFORM (domain) USING '/opt/cloudera/parcels/Anaconda/bin/python3.6 testbeforebreak.py'
AS (lower_domain) FROM siem.maliciousurls limit 10;

SELECT TRANSFORM (domain)
USING '/opt/cloudera/parcels/Anaconda/bin/python3.6 urllearningcoef.py' AS
(url_length int, massiveurl int, count_at int, count_dot int, url_is_ip int, url_kl_en float, count_dot_com int,url_ks_en float)
FROM siem.maliciousurls where domain is not null and uri not in(null,'',' ');

*/