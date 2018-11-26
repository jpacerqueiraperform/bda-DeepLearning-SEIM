#!/usr/bin/env bash
# USING OPTION : phishtank

export http_proxy="http://proxy:3128"
#export https_proxy="https://proxy:3128"

#wget http://data.phishtank.com/data/online-valid.json.bz2
#wget http://data.phishtank.com/data/online-valid.csv.bz2
wget http://data.phishtank.com/data/verified_online.json.bz2
wget http://data.phishtank.com/data/verified_online.csv.bz2

unset http_proxy
#unset https_proxy

echo "DONE!"
