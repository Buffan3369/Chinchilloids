#!/bin/bash

python3 ~/CorsaiR/assess_run_convergence.py -ana "BDNN" -dir ../BDNN/default_arch/pyrate_mcmc_logs
Rscript ~/CorsaiR/plot_ess.r ../BDNN/default_arch/pyrate_mcmc_logs/ESS_summary.txt ../BDNN/default_arch/pyrate_mcmc_logs/ESS_plot.png

