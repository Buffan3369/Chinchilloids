#!/bin/bash

declare -A burnin=([genus/1-Full]=0.01 [genus/2-Singleton]=0.1 [genus/3-Spatially_scaled]=0.25 \
				   [species/1-Full]=0.01 [species/2-Singleton]=0.01 [species/3-NoCaribbea]=0.01 \
				   [species/4-Tropical]=0.01 [species/5-Extratropical]=0.01 \
				   [species_extant_extended/1-Full]=0.01 [species_extant_extended/2-Singleton]=0.01 \
				   [species_extant_extended/3-NoCar]=0.01)

# Extant assigned one occurrence of modern age
# ana=species
# for pth in 1-Full 2-Singleton 3-NoCaribbea 4-Tropical 5-Extratropical
# do
# 	# For each individual retained run
# 	for file in ../Results/RJMCMC/$ana/$pth/pyrate_mcmc_logs/*_KEEP_mcmc.log
# 	do
# 		python ~/PyRate/PyRate.py -plotQ ${file} -qShift ../Data/time_bins/geological_stages.txt -b ${burnin[$ana/$pth]}
# 	done
# 	# Parse and save individual q_rates to compile them in a table
# 	mkdir -p ../Results/RJMCMC/$ana/$pth/Q_SHIFTS
# 	mv ../Results/RJMCMC/$ana/$pth/pyrate_mcmc_logs/*_Qrates* ../Results/RJMCMC/$ana/$pth/Q_SHIFTS/
# 	python ~/Documents/GitHub/CorsaiR/Python/parse_Q_rates.py -q_dir ../Results/RJMCMC/$ana/$pth/Q_SHIFTS/ -bin_dir ../Data/time_bins/geological_stages.txt -out ../Results/RJMCMC/$ana/$pth/Q_SHIFTS/Parsed_Q_rates.txt
# done

# Extant extended
ana=species_extant_extended
for pth in 1-Full
do
	# For each individual retained run
	for file in ../Results/RJMCMC/$ana/$pth/pyrate_mcmc_logs/*_KEEP_mcmc.log
	do
		python ~/PyRate/PyRate.py -plotQ ${file} -qShift ../Data/time_bins/geological_stages.txt -b ${burnin[$ana/$pth]}
	done
	# Parse and save individual q_rates to compile them in a table
	mkdir -p ../Results/RJMCMC/$ana/$pth/Q_SHIFTS
	mv ../Results/RJMCMC/$ana/$pth/pyrate_mcmc_logs/*_Qrates* ../Results/RJMCMC/$ana/$pth/Q_SHIFTS/
	python ~/Documents/GitHub/CorsaiR/Python/parse_Q_rates.py -q_dir ../Results/RJMCMC/$ana/$pth/Q_SHIFTS/ -bin_dir ../Data/time_bins/geological_stages.txt -out ../Results/RJMCMC/$ana/$pth/Q_SHIFTS/Parsed_Q_rates.txt
done

## Genus Spatially Scaled ##
# For each individual retained run
# for file in ../Results/RJMCMC/genus/3-Spatially_scaled/pyrate_mcmc_logs/*_KEEP_mcmc.log
# do
# 	python ~/PyRate/PyRate.py -plotQ ${file} -qShift ../Data/time_bins/geological_stages.txt -b ${burnin[genus/3-Spatially_scaled]}
# done
# # Parse and save individual q_rates to compile them in a table
# mkdir -p ../Results/RJMCMC/genus/3-Spatially_scaled/Q_SHIFTS
# mv ../Results/RJMCMC/genus/3-Spatially_scaled/pyrate_mcmc_logs/*_Qrates* ../Results/RJMCMC/genus/3-Spatially_scaled/Q_SHIFTS/
# python ~/Documents/GitHub/CorsaiR/Python/parse_Q_rates.py -q_dir ../Results/RJMCMC/genus/3-Spatially_scaled/Q_SHIFTS/ -bin_dir ../Data/time_bins/geological_stages.txt -out ../Results/RJMCMC/genus/3-Spatially_scaled/Q_SHIFTS/Parsed_Q_rates.txt
