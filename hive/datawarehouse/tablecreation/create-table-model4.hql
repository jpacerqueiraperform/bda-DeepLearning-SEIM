CREATE EXTERNAL TABLE `siem`.`url_phishing_model4_prediction`
(
  `url` string ,
  `ynverified` int ,
  `url_length` int ,
  `massiveurl` int ,
  `count_at` int ,
  `count_dot` int ,
  `url_is_ip` int ,
  `count_dot_com` int ,
  `url_kl_en` double ,
  `url_bad_kl_en` int ,
  `url_ks_en` double ,
  `url_bad_ks_en` int ,
  `url_kl_phish` double ,
  `url_bad_kl_phish` int ,
  `url_ks_phish` double ,
  `url_bad_ks_phish` int ,
  `url_bad_words_domain` int ,
  `url_entropy_en` double ,
  `url_bad_entropy_en` int ,
  `url_entropy_phish` double ,
  `url_bad_entropy_phish` int ,
  `mdl_score_phishing` double ) PARTITIONED BY (
  `dt` int )
ROW FORMAT   SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
  WITH SERDEPROPERTIES ("separatorChar" = ",",
    "quoteChar"     = "\"",
    "escapeChar"    = "\\"
    )
  STORED AS TextFile LOCATION '/user/siemanalyst/data/staged/url_phishing_model4_prediction'
TBLPROPERTIES("skip.header.line.count" = "1");
