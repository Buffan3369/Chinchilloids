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
# 	#Combine log files for runs that converged
# 	python ~/PyRate/PyRate.py -combLogRJ ../Results/RJMCMC/$ana/$pth/pyrate_mcmc_logs -tag KEEP -b ${burnin[$ana/$pth]}
# 	mkdir -p ../Results/RJMCMC/$ana/$pth/combined_logs
# 	mv ../Results/RJMCMC/$ana/$pth/pyrate_mcmc_logs/combined_* ../Results/RJMCMC/$ana/$pth/combined_logs
# 	#Plot RTT
# 	python ~/PyRate/PyRate.py -plotRJ ../Results/RJMCMC/$ana/$pth/combined_logs -b ${burnin[$ana/$pth]}
# 	Rscript ../Results/RJMCMC/$ana/$pth/combined_logs/RTT_plots.r
# 	#Plot LTT
# 	mkdir -p ../Results/RJMCMC/$ana/$pth/LTT/
# 	python ~/PyRate/PyRate.py -ginput ../Results/RJMCMC/$ana/$pth/pyrate_mcmc_logs -tag KEEP_ -b ${burnin[$ana/$pth]}
# 	mv ../Results/RJMCMC/$ana/$pth/pyrate_mcmc_logs/*_se_est.txt ../Results/RJMCMC/$ana/$pth/LTT/
# 	mv ../Results/RJMCMC/$ana/$pth/combined_logs/*_LTT.r ../Results/RJMCMC/$ana/$pth/LTT/
# 	#Diversity-through-time (median, min and max diversity)
# 	python ~/PyRate/PyRate.py -d ../Results/RJMCMC/$ana/$pth/LTT/*_se_est.txt -ltt 1
# done

# Extant extended
ana=species_extant_extended
for pth in 1-Full
do
	#Combine log files for runs that converged
	python ~/PyRate/PyRate.py -combLogRJ ../Results/RJMCMC/$ana/$pth/pyrate_mcmc_logs -tag KEEP -b ${burnin[$ana/$pth]}
	mkdir -p ../Results/RJMCMC/$ana/$pth/combined_logs
	mv ../Results/RJMCMC/$ana/$pth/pyrate_mcmc_logs/combined_* ../Results/RJMCMC/$ana/$pth/combined_logs
	#Plot RTT
	python ~/PyRate/PyRate.py -plotRJ ../Results/RJMCMC/$ana/$pth/combined_logs -b ${burnin[$ana/$pth]}
	Rscript ../Results/RJMCMC/$ana/$pth/combined_logs/RTT_plots.r
	#Plot LTT
	mkdir -p ../Results/RJMCMC/$ana/$pth/LTT/
	python ~/PyRate/PyRate.py -ginput ../Results/RJMCMC/$ana/$pth/pyrate_mcmc_logs -tag KEEP_ -b ${burnin[$ana/$pth]}
	mv ../Results/RJMCMC/$ana/$pth/pyrate_mcmc_logs/*_se_est.txt ../Results/RJMCMC/$ana/$pth/LTT/
	mv ../Results/RJMCMC/$ana/$pth/combined_logs/*_LTT.r ../Results/RJMCMC/$ana/$pth/LTT/
	#Diversity-through-time (median, min and max diversity)
	python ~/PyRate/PyRate.py -d ../Results/RJMCMC/$ana/$pth/LTT/*_se_est.txt -ltt 1
done

## Genus Spatially Scaled ##
#Combine log files for runs that converged
# python ~/PyRate/PyRate.py -combLogRJ ../Results/RJMCMC/genus/3-Spatially_scaled/pyrate_mcmc_logs -tag KEEP -b ${burnin[genus/3-Spatially_scaled]}
# mkdir -p ../Results/RJMCMC/genus/3-Spatially_scaled/combined_logs
# mv ../Results/RJMCMC/genus/3-Spatially_scaled/pyrate_mcmc_logs/combined_* ../Results/RJMCMC/genus/3-Spatially_scaled/combined_logs
# #Plot RTT
# python ~/PyRate/PyRate.py -plotRJ ../Results/RJMCMC/genus/3-Spatially_scaled/combined_logs -b ${burnin[genus/3-Spatially_scaled]}
# Rscript ../Results/RJMCMC/genus/3-Spatially_scaled/combined_logs/RTT_plots.r
# #Plot LTT
# mkdir -p ../Results/RJMCMC/genus/3-Spatially_scaled/LTT/
# python ~/PyRate/PyRate.py -ginput ../Results/RJMCMC/genus/3-Spatially_scaled/pyrate_mcmc_logs -tag KEEP_ -b ${burnin[genus/3-Spatially_scaled]}
# mv ../Results/RJMCMC/genus/3-Spatially_scaled/pyrate_mcmc_logs/*_se_est.txt ../Results/RJMCMC/genus/3-Spatially_scaled/LTT/
# mv ../Results/RJMCMC/genus/3-Spatially_scaled/combined_logs/*_LTT.r ../Results/RJMCMC/genus/3-Spatially_scaled/LTT/
# #Diversity-through-time (median, min and max diversity)
# python ~/PyRate/PyRate.py -d ../Results/RJMCMC/genus/3-Spatially_scaled/LTT/*_se_est.txt -ltt 1
