#!/bin/bash

# # Combine BDNN mcmc log files
# python3 ~/PyRate/PyRate.py -combBDNN ../BDNN/default_arch/pyrate_mcmc_logs/ -tag KEEP -resample 100

# # Move combined log in a desired folder
# mkdir -p ../BDNN/default_arch/combined_logs
# mv ../BDNN/default_arch/pyrate_mcmc_logs/combined* ../BDNN/default_arch/combined_logs

# # Combine BDNN mcmc log files
# python3 ~/PyRate/PyRate.py -combBDNN ../../Results/BDNN/Extended_extant/pyrate_mcmc_logs/ -tag KEEP -resample 100

# # Move combined log in a desired folder
# mkdir -p ../../Results/BDNN/Extended_extant/combined_logs
# mv ../../Results/BDNN/Extended_extant/pyrate_mcmc_logs/combined* ../../Results/BDNN/Extended_extant/combined_logs

## IMPUTATIONS ##

for i in {1..10}
do
    python3 ~/PyRate/PyRate.py -combBDNN ../../Results/BDNN/BDNN_imputation_NoCar-NewComb/Input/Replicate_$i/pyrate_mcmc_logs/ -tag KEEP -resample 100
    # Move combined log in a desired folder
    mkdir -p ../../Results/BDNN/BDNN_imputation_NoCar-NewComb/Input/Replicate_$i/combined_logs
    mv ../../Results/BDNN/BDNN_imputation_NoCar-NewComb/Input/Replicate_$i/pyrate_mcmc_logs/combined* ../../Results/BDNN/BDNN_imputation_NoCar-NewComb/Input/Replicate_$i/combined_logs
done
~                             
