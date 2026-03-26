#!/bin/bash

#########################################################
## ------------------ Species-level ------------------ ##
#########################################################

## Standard analyses
for pth in 1-Full 3-NoCar
do
    python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../Results/RJMCMC/AMD-45/species/$pth/pyrate_mcmc_logs
    Rscript ~/Documents/GitHub/CorsaiR/R/plot_ess.r ../Results/RJMCMC/AMD-45/species/$pth/pyrate_mcmc_logs/ESS_summary.txt ../Results/RJMCMC/AMD-45/species/$pth/pyrate_mcmc_logs/ESS_plot.png
done


#######################################################
## ------------------ Genus-level ------------------ ##
#######################################################

for pth in 1-Full 3-Spatially_scaled
do
    python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../Results/RJMCMC/AMD-45/genus/$pth/pyrate_mcmc_logs
    Rscript ~/Documents/GitHub/CorsaiR/R/plot_ess.r ../Results/RJMCMC/AMD-45/genus/$pth/pyrate_mcmc_logs/ESS_summary.txt ../Results/RJMCMC/AMD-45/genus/$pth/pyrate_mcmc_logs/ESS_plot.png
done