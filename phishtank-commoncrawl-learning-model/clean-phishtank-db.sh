#!/usr/bin/env bash
# USING OPTION : phishtank

mv verified_online.json.bz2 siem/
mv verified_online.csv.bz2 siem/
bzip2 -dk siem/verified_online.json.bz2
bzip2 -dk siem/verified_online.csv.bz2
sed -i 's/,yes,/,1,/g' siem/verified_online.csv
sed -i 's/,no,/,0,/g' siem/verified_online.csv

hdfs dfs -copyFromLocal -f siem/verified_online.json data/raw/phishtank/dt=20181112
hdfs dfs -copyFromLocal -f siem/verified_online.csv data/raw/phishtank/dt=20181112
