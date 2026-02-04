#!/bin/bash

for ana in species
do
	for pth in 1-Full 2-Singleton
	do
		python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../Results/RJMCMC/$ana/$pth/pyrate_mcmc_logs
		Rscript ~/Documents/GitHub/CorsaiR/R/plot_ess.r ../Results/RJMCMC/$ana/$pth/pyrate_mcmc_logs/ESS_summary.txt ../Results/RJMCMC/$ana/$pth/pyrate_mcmc_logs/ESS_plot.png
	done
done

## Genus Spatially Scaled ##
#python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../Results/RJMCMC/genus/3-Spatially_scaled/pyrate_mcmc_logs
#Rscript ~/Documents/GitHub/CorsaiR/R/plot_ess.r ../Results/RJMCMC/genus/3-Spatially_scaled/pyrate_mcmc_logs/ESS_summary.txt ../Results/RJMCMC/genus/3-Spatially_scaled/pyrate_mcmc_logs/ESS_plot.png

## Species without Caribbean taxa ##
#python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../Results/RJMCMC/species/3-NoCaribbea/pyrate_mcmc_logs
#Rscript ~/Documents/GitHub/CorsaiR/R/plot_ess.r ../Results/RJMCMC/species/3-NoCaribbea/pyrate_mcmc_logs/ESS_summary.txt ../Results/RJMCMC/species/3-NoCaribbea/pyrate_mcmc_logs/ESS_plot.png
