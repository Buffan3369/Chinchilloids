#!/bin/bash

# for s in species genus
# do
#     python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/BDCS/$s/pyrate_mcmc_logs -ana BDS
#     Rscript ~/Documents/GitHub/CorsaiR/R/plot_ess.r ../../Results/BDCS/$s/pyrate_mcmc_logs/ESS_summary.txt ../../Results/BDCS/$s/pyrate_mcmc_logs/ESS_plot.png
# done

for s in species genus
do
    python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/BDCS_new_bins/$s/pyrate_mcmc_logs -ana BDS
    Rscript ~/Documents/GitHub/CorsaiR/R/plot_ess.r ../../Results/BDCS_new_bins/$s/pyrate_mcmc_logs/ESS_summary.txt ../../Results/BDCS_new_bins/$s/pyrate_mcmc_logs/ESS_plot.png
done