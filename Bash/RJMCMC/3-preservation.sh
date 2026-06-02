#!/bin/bash

#########################################################
## ------------------ Species-level ------------------ ##
#########################################################

# for pth in 1-Full 2-Singleton 3-NoCaribbea
# do
# 	# For each individual retained run
# 	for file in ../../Results/RJMCMC/species/$pth/pyrate_mcmc_logs/*_KEEP_mcmc.log
# 	do
# 		python ~/PyRate/PyRate.py -plotQ ${file} -qShift ../../Data/time_bins/geological_stages.txt -b 10
# 	done
# 	# Parse and save individual q_rates to compile them in a table
# 	mkdir -p ../../Results/RJMCMC/species/$pth/Q_SHIFTS
# 	mv ../../Results/RJMCMC/species/$pth/pyrate_mcmc_logs/*_Qrates* ../../Results/RJMCMC/species/$pth/Q_SHIFTS/
# 	python ~/Documents/GitHub/CorsaiR/Python/parse_Q_rates.py -q_dir ../../Results/RJMCMC/species/$pth/Q_SHIFTS/ -bin_dir ../../Data/time_bins/geological_stages.txt -out ../../Results/RJMCMC/species/$pth/Q_SHIFTS/Parsed_Q_rates.txt
# done


#######################################################
## ------------------ Genus-level ------------------ ##
#######################################################

for pth in 1-Full 2-Singleton 3-Spatially_scaled 4-NoIndet
do
# For each individual retained run
	for file in ../../Results/RJMCMC/genus/$pth/pyrate_mcmc_logs/*_KEEP_mcmc.log
	do
		python ~/PyRate/PyRate.py -plotQ ${file} -qShift ../../Data/time_bins/geological_stages.txt -b 10
	done
	# Parse and save individual q_rates to compile them in a table
	mkdir -p ../../Results/RJMCMC/genus/$pth/Q_SHIFTS
	mv ../../Results/RJMCMC/genus/$pth/pyrate_mcmc_logs/*_Qrates* ../../Results/RJMCMC/genus/$pth/Q_SHIFTS/
	python ~/Documents/GitHub/CorsaiR/Python/parse_Q_rates.py -q_dir ../../Results/RJMCMC/genus/$pth/Q_SHIFTS/ -bin_dir ../../Data/time_bins/geological_stages.txt -out ../../Results/RJMCMC/genus/$pth/Q_SHIFTS/Parsed_Q_rates.txt
done