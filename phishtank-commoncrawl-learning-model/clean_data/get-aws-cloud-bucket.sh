#!/usr/bin/env bash
# USING OPTION : phishtank

export http_proxy="http://proxy:3128"
export https_proxy="https://proxy:3128"

# Import a sample binary outcome train/test set into H2O
wget https://s3.amazonaws.com/erin-data/higgs/higgs_train_10k.csv -O datafiles/higgs_train_10k.csv
wget https://s3.amazonaws.com/erin-data/higgs/higgs_test_5k.csv -O datafiles/higgs_test_5k.csv


