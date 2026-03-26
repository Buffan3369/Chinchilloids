#!/bin/bash

#########################################################
## ------------------ Species-level ------------------ ##
#########################################################

for pth in 1-Full 3-NoCar
do
	# For each individual retained run
	for file in ../Results/RJMCMC/AMD-45/species/$pth/pyrate_mcmc_logs/*_KEEP_mcmc.log
	do
		python ~/PyRate/PyRate.py -plotQ ${file} -qShift ../Data/time_bins/geological_stages.txt -b 10
	done
	# Parse and save individual q_rates to compile them in a table
	mkdir -p ../Results/RJMCMC/AMD-45/species/$pth/Q_SHIFTS
	mv ../Results/RJMCMC/AMD-45/species/$pth/pyrate_mcmc_logs/*_Qrates* ../Results/RJMCMC/AMD-45/species/$pth/Q_SHIFTS/
	python ~/Documents/GitHub/CorsaiR/Python/parse_Q_rates.py -q_dir ../Results/RJMCMC/AMD-45/species/$pth/Q_SHIFTS/ -bin_dir ../Data/time_bins/geological_stages.txt -out ../Results/RJMCMC/AMD-45/species/$pth/Q_SHIFTS/Parsed_Q_rates.txt
done


#######################################################
## ------------------ Genus-level ------------------ ##
#######################################################

for pth in 1-Full 3-Spatially_scaled
do
# For each individual retained run
	for file in ../Results/RJMCMC/AMD-45/genus/$pth/pyrate_mcmc_logs/*_KEEP_mcmc.log
	do
		python ~/PyRate/PyRate.py -plotQ ${file} -qShift ../Data/time_bins/geological_stages.txt -b 10
	done
	# Parse and save individual q_rates to compile them in a table
	mkdir -p ../Results/RJMCMC/AMD-45/genus/$pth/Q_SHIFTS
	mv ../Results/RJMCMC/AMD-45/genus/$pth/pyrate_mcmc_logs/*_Qrates* ../Results/RJMCMC/AMD-45/genus/$pth/Q_SHIFTS/
	python ~/Documents/GitHub/CorsaiR/Python/parse_Q_rates.py -q_dir ../Results/RJMCMC/AMD-45/genus/$pth/Q_SHIFTS/ -bin_dir ../Data/time_bins/geological_stages.txt -out ../Results/RJMCMC/AMD-45/genus/$pth/Q_SHIFTS/Parsed_Q_rates.txt
done