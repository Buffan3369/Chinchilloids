#!/bin/bash

## CARNIVORA ##
#Combine log files for runs that converged
python ~/PyRate/PyRate.py -combLogRJ ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/pyrate_mcmc_logs -tag KEEP -b 10
mkdir -p ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/combined_logs
mv ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/pyrate_mcmc_logs/combined_* ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/combined_logs
#Plot RTT
python ~/PyRate/PyRate.py -plotRJ ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/combined_logs -b 10
Rscript ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/combined_logs/RTT_plots.r
#Plot LTT
mkdir -p ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/LTT/
python ~/PyRate/PyRate.py -ginput ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/pyrate_mcmc_logs -tag KEEP_ -b 10
mv ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/pyrate_mcmc_logs/*_se_est.txt ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/LTT/
mv ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/combined_logs/*_LTT.r ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/LTT/
#Diversity-through-time (median, min and max diversity)
python ~/PyRate/PyRate.py -d ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/LTT/*_se_est.txt -ltt 1

## Northern Herbivores ##
#Combine log files for runs that converged
python ~/PyRate/PyRate.py -combLogRJ ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/pyrate_mcmc_logs -tag KEEP -b 10
mkdir -p ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/combined_logs
mv ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/pyrate_mcmc_logs/combined_* ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/combined_logs
#Plot RTT
python ~/PyRate/PyRate.py -plotRJ ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/combined_logs -b 10
Rscript ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/combined_logs/RTT_plots.r
#Plot LTT
mkdir -p ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/LTT/
python ~/PyRate/PyRate.py -ginput ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/pyrate_mcmc_logs -tag KEEP_ -b 10
mv ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/pyrate_mcmc_logs/*_se_est.txt ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/LTT/
mv ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/combined_logs/*_LTT.r ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/LTT/
#Diversity-through-time (median, min and max diversity)
python ~/PyRate/PyRate.py -d ../../Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/LTT/*_se_est.txt -ltt 1
