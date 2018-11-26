#!/usr/bin/env bash
# USING OPTION : phishtank

if [ -n "$1" ]; then
  DAILY=$1
else
  DAILY=20181128
fi

mv verified_online.json.bz2 datafiles/
mv verified_online.csv.bz2 datafiles/
bzip2 -dk datafiles/verified_online.json.bz2
bzip2 -dk datafiles/verified_online.csv.bz2
sed -i 's/,yes,/,1,/g' datafiles/verified_online.csv
sed -i 's/,no,/,0,/g' datafiles/verified_online.csv

hdfs dfs -copyFromLocal -f datafiles/verified_online.json data/raw/phishtank/dt=${DAILY}
hdfs dfs -copyFromLocal -f datafiles/verified_online.csv data/raw/phishtank/dt=${DAILY}

