#!/usr/bin/env bash
# USING OPTION :

if [ -n "$1" ]; then
  DAILY=$1
else
  DAILY=20181128
fi

cd /home/siemanalyst/notebooks/siem/clean_data/
./get-aws-cloud-bucket.sh ${DAILY} > last_execution.log
./get-commomcrawl-url.sh ${DAILY} >> last_execution.log
./get-phishtank-db.sh ${DAILY} >> last_execution.log
./get-aws-cloud-bucket.sh ${DAILY} >> last_execution.log
./clean-json-commomcrawl-url.sh ${DAILY} >> last_execution.log
./clean-phishtank-db.sh ${DAILY} >> last_execution.log
