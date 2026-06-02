#!/bin/bash

#########################################################
## ------------------ Species-level ------------------ ##
#########################################################

## Standard analyses
# for pth in 1-Full 2-Singleton 3-NoCaribbea
# do
#     python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/RJMCMC/species/$pth/pyrate_mcmc_logs
#     Rscript ~/Documents/GitHub/CorsaiR/R/plot_ess.r ../../Results/RJMCMC/species/$pth/pyrate_mcmc_logs/ESS_summary.txt ../../Results/RJMCMC/species/$pth/pyrate_mcmc_logs/ESS_plot.png
# done


#######################################################
## ------------------ Genus-level ------------------ ##
#######################################################

for pth in 1-Full 2-Singleton 3-Spatially_scaled 4-NoIndet
do
    python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/RJMCMC/genus/$pth/pyrate_mcmc_logs
    Rscript ~/Documents/GitHub/CorsaiR/R/plot_ess.r ../../Results/RJMCMC/genus/$pth/pyrate_mcmc_logs/ESS_summary.txt ../../Results/RJMCMC/genus/$pth/pyrate_mcmc_logs/ESS_plot.png
done


