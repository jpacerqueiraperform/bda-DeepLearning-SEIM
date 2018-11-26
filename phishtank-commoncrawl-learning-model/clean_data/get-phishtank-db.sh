#!/usr/bin/env bash
# USING OPTION : phishtank

if [ -n "$1" ]; then
  DAILY=$1
else
  DAILY=20181128
fi
export http_proxy="http://proxy:3128"
export https_proxy="https://proxy:3128"

wget http://data.phishtank.com/data/online-valid.json.bz2
wget http://data.phishtank.com/data/online-valid.csv.bz2
wget http://data.phishtank.com/data/verified_online.json.bz2
wget http://data.phishtank.com/data/verified_online.csv.bz2

unset http_proxy
unset https_proxy

echo "DONE!"
