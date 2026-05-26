#!/bin/bash

for s in genus
do
	#Combine logs
	python ~/PyRate/PyRate.py -combLog ../../Results/BDCS/$s/pyrate_mcmc_logs -tag KEEP_BDS_mcmc -b 10
	python ~/PyRate/PyRate.py -combLog ../../Results/BDCS/$s/pyrate_mcmc_logs -tag KEEP_BDS_marginal_rates -b 10
	mkdir -p ../../Results/BDCS/$s/combined_logs
	mv ../../Results/BDCS/$s/pyrate_mcmc_logs/combined_* ../../Results/BDCS/$s/combined_logs
	#Plot RTT
	python ~/PyRate/PyRate.py -plot2 ../../Results/BDCS/$s/combined_logs -b 10
done

# for s in species genus
# do
# 	#Combine logs
# 	python ~/PyRate/PyRate.py -combLog ../../Results/BDCS_new_bins/$s/pyrate_mcmc_logs -tag KEEP_BDS_mcmc -b 10
# 	python ~/PyRate/PyRate.py -combLog ../../Results/BDCS_new_bins/$s/pyrate_mcmc_logs -tag KEEP_BDS_marginal_rates -b 10
# 	mkdir -p ../../Results/BDCS_new_bins/$s/combined_logs
# 	mv ../../Results/BDCS_new_bins/$s/pyrate_mcmc_logs/combined_* ../../Results/BDCS_new_bins/$s/combined_logs
# 	#Plot RTT
# 	python ~/PyRate/PyRate.py -plot2 ../../Results/BDCS_new_bins/$s/combined_logs -b 10
# done