#!/bin/bash

declare -A burnin=([genus/1-Full]=0.01 [genus/2-Singleton]=0.1 [genus/3-Spatially_scaled]=0.25 \
				   [species/1-Full]=0.01 [species/2-Singleton]=0.01 [species/3-NoCaribbea]=0.01)

for ana in species
do
	for pth in 1-Full 2-Singleton
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

# ## Species without Caribbean taxa ##
# #Combine log files for runs that converged
# python ~/PyRate/PyRate.py -combLogRJ ../Results/RJMCMC/species/3-NoCaribbea/pyrate_mcmc_logs -tag KEEP -b ${burnin[species/3-NoCaribbea]}
# mkdir -p ../Results/RJMCMC/species/3-NoCaribbea/combined_logs
# mv ../Results/RJMCMC/species/3-NoCaribbea/pyrate_mcmc_logs/combined_* ../Results/RJMCMC/species/3-NoCaribbea/combined_logs
# #Plot RTT
# python ~/PyRate/PyRate.py -plotRJ ../Results/RJMCMC/species/3-NoCaribbea/combined_logs -b ${burnin[species/3-NoCaribbea]}
# Rscript ../Results/RJMCMC/species/3-NoCaribbea/combined_logs/RTT_plots.r
# #Plot LTT
# mkdir -p ../Results/RJMCMC/species/3-NoCaribbea/LTT/
# python ~/PyRate/PyRate.py -ginput ../Results/RJMCMC/species/3-NoCaribbea/pyrate_mcmc_logs -tag KEEP_ -b ${burnin[species/3-NoCaribbea]}
# mv ../Results/RJMCMC/species/3-NoCaribbea/pyrate_mcmc_logs/*_se_est.txt ../Results/RJMCMC/species/3-NoCaribbea/LTT/
# mv ../Results/RJMCMC/species/3-NoCaribbea/combined_logs/*_LTT.r ../Results/RJMCMC/species/3-NoCaribbea/LTT/
# #Diversity-through-time (median, min and max diversity)
# python ~/PyRate/PyRate.py -d ../Results/RJMCMC/species/3-NoCaribbea/LTT/*_se_est.txt -ltt 1