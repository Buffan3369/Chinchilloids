#!/bin/bash

# Combine BDNN mcmc log files
python3 ~/PyRate/PyRate.py -combBDNN ../BDNN/default_arch/pyrate_mcmc_logs/ -tag KEEP -resample 100

# Move combined log in a desired folder
mkdir -p ../BDNN/default_arch/combined_logs
mv ../BDNN/default_arch/pyrate_mcmc_logs/combined* ../BDNN/default_arch/combined_logs
