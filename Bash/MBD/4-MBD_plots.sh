#!/bin/bash

# Species-level dataset with scaled predictors
#python ~/PyRate/PyRateMBD.py -d ../../Results/MBD/species/MBD_scaled/1-Chinchilloidea_sp_lvl_occ_10_Grj_KEEP_se_est.txt \
#-var ../../Data/MBD_predictors_Scaled_for_plot -plot ../../Results/MBD/species/MBD_scaled/combined_18_KEEP.log

# Species-level dataset with scaled predictors and disabling horseshoe prior
#python ~/PyRate/PyRateMBD.py -d ../../Results/MBD/species/MBD_scaled_hsp0/1-Chinchilloidea_sp_lvl_occ_10_Grj_KEEP_se_est.txt \
#-var ../../Data/MBD_predictors_Scaled_for_plot -plot ../../Results/MBD/species/MBD_scaled_hsp0/combined_18_KEEP.log

# Species-level dataset (extant species extended) with scaled predictors and disabling horseshoe prior
#python ~/PyRate/PyRateMBD.py -d ../../Results/MBD/species_extant_extended/1-Chinchilloidea_sp_lvl_occ_EXTENDED_10_Grj_KEEP_se_est.txt \
#-var ../../Data/MBD_predictors_Scaled_for_plot -plot ../../Results/MBD/species_extant_extended/combined_20_KEEP.log

# Species-level dataset (extant species extended) with scaled predictors and disabling horseshoe prior − unphased predictors
#python ~/PyRate/PyRateMBD.py -d ../../Results/MBD/unphased/MBD_scaled_unphased_hsp0/1-Chinchilloidea_sp_lvl_occ_EXTENDED_10_Grj_KEEP_se_est.txt \
#-var ../../Data/MBD_predictors_scaled_unphased -plot ../../Results/MBD/unphased/MBD_scaled_unphased_hsp0/combined_20_KEEP.log

# Species-level dataset (extant species extended) with scaled predictors − unphased predictors
#python ~/PyRate/PyRateMBD.py -d ../../Results/MBD/unphased/MBD_scaled_unphased/1-Chinchilloidea_sp_lvl_occ_EXTENDED_10_Grj_se_est.txt \
#-var ../../Data/MBD_predictors_scaled_unphased -plot ../../Results/MBD/unphased/MBD_scaled_unphased/combined_17_KEEP.log

# Species-level dataset (extant species extended) gamma prior scaled predictors No diversity-dependence
# python ~/PyRate/PyRateMBD.py -d ../../Results/MBD/species_rmDD/1-Chinchilloidea_sp_lvl_occ_EXTENDED_10_Grj_se_est.txt \
# -var ../../Data/MBD_predictors_Scaled_for_plot -rmDD 1 -plot ../../Results/MBD/species_rmDD/combined_20_KEEP.log

# Newest dataset (AMD-45 + Ituzaingó revised)
python ~/PyRate/PyRateMBD.py -d ../../Results/MBD/species_hsp0/Chinchilloidea_species_Continental.txt \
-var ../../Data/MBD_predictors_Scaled_for_plot -plot ../../Results/MBD/species_hsp0/combined_18_KEEP.log