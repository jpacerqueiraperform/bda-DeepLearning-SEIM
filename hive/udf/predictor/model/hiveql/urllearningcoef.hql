DELETE JAR h2o-genmodel.jar;
DELETE JAR ScoreDataUDFAUTOML-1.0-SNAPSHOT.jar;
ADD JAR hdfs:////user/siemanalyst/predictor/udf/StackedEnsemble_AllModels_AutoML/h2o-genmodel.jar;
ADD JAR hdfs:///user/siemanalyst/predictor/udf/StackedEnsemble_AllModels_AutoML/ScoreDataUDFAUTOML-1.0-SNAPSHOT.jar;

CREATE TEMPORARY FUNCTION scoredatav1 AS 'ai.h2o.hive.udf.ScoreDataUDFv1';
CREATE TEMPORARY FUNCTION scoredatav2 AS 'ai.h2o.hive.udf.ScoreDataM2UDF';

MSCK REPAIR TABLE siem.urltopredict ;
select * from siem.urltopredict limit 10;

SELECT url, scoredatav2(ynverified,url_length,massiveurl,count_at,count_dot,url_is_ip,count_dot_com,url_kl_en,url_bad_kl_en,url_ks_en,url_bad_ks_en) score_phishing
FROM siem.urltopredict where url is not null limit 100000 ;



SELECT COUNT(DISTINCT url)  from siem.urltopredict  where url is not null group by url ;

/*
 , ynverified, url_length, massiveurl, count_at, count_dot, url_is_ip, count_dot_com, url_kl_en, url_bad_kl_en, url_ks_en, url_bad_ks_en

;  requires:
  [url_length, massiveurl, count_at, count_dot, url_is_ip, url_kl_en, count_dot_com, url_ks_en]
    predictes : [ynverified],

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