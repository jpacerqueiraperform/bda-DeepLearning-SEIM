#!/usr/bin/env bash
# USING OPTION : phishtank

wget http://data.phishtank.com/data/online-valid.json.bz2 
wget http://data.phishtank.com/data/online-valid.csv.bz2 
mv online-valid.json.bz2 seim/
mv online-valid.csv.bz2 seim/
bzip2 -dk seim/online-valid.json.bz2
bzip2 -dk seim/online-valid.csv.bz2
sed -i 's/,yes,/,1,/g' seim/online-valid.csv
sed -i 's/,no,/,0,/g' seim/online-valid.csv
