#!/bin/bash

# Carnivora
python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/pyrate_mcmc_logs
Rscript ~/Documents/GitHub/CorsaiR/R/plot_ess.r ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/pyrate_mcmc_logs/ESS_summary.txt ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/pyrate_mcmc_logs/ESS_plot.png

# Northern herbivores
python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/pyrate_mcmc_logs -thr 100
Rscript ~/Documents/GitHub/CorsaiR/R/plot_ess.r ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/pyrate_mcmc_logs/ESS_summary.txt ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/pyrate_mcmc_logs/ESS_plot.png
