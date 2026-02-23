#!/bin/bash

#python3 ~/CorsaiR/assess_run_convergence.py -ana "BDNN" -dir ../BDNN/default_arch/pyrate_mcmc_logs
#Rscript ~/CorsaiR/plot_ess.r ../BDNN/default_arch/pyrate_mcmc_logs/ESS_summary.txt ../BDNN/default_arch/pyrate_mcmc_logs/ESS_plot.png

python3 ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -ana "BDNN" -dir ../../Results/BDNN/Extended_extant/pyrate_mcmc_logs
Rscript ~/Documents/GitHub/CorsaiR/R/plot_ess.r ../../Results/BDNN/Extended_extant/pyrate_mcmc_logs/ESS_summary.txt ../../Results/BDNN/Extended_extant/pyrate_mcmc_logs/ESS_plot.png
