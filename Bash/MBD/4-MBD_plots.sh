#!/bin/bash

# Species-level dataset with scaled predictors
#python ~/PyRate/PyRateMBD.py -d ../../Results/MBD/species/MBD_scaled/1-Chinchilloidea_sp_lvl_occ_10_Grj_KEEP_se_est.txt \
#-var ../../Data/MBD_predictors_Scaled_for_plot -plot ../../Results/MBD/species/MBD_scaled/combined_18_KEEP.log

# Species-level dataset with scaled predictors and disabling horseshoe prior
python ~/PyRate/PyRateMBD.py -d ../../Results/MBD/species/MBD_scaled_hsp0/1-Chinchilloidea_sp_lvl_occ_10_Grj_KEEP_se_est.txt \
-var ../../Data/MBD_predictors_Scaled_for_plot -plot ../../Results/MBD/species/MBD_scaled_hsp0/combined_18_KEEP.log