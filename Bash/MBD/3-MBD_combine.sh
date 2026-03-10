#!/bin/bash

# Species-level dataset
#python ~/PyRate/PyRate.py -combLog ../../Results/MBD/species/Classical -tag _KEEP -resample 100 -b 10

# Species-level dataset with scaled predictors
#python ~/PyRate/PyRate.py -combLog ../../Results/MBD/species/MBD_scaled -tag _KEEP -resample 100 -b 10

# Species-level dataset with scaled predictors + Carnivora and North American herbivore diversities
#python ~/PyRate/PyRate.py -combLog ../../Results/MBD/species/MBD_scaled_migrants -tag _KEEP -resample 100 -b 10

# Species-level dataset with scaled predictors + Carnivora and North American herbivore diversities (temporally unextended)
#python ~/PyRate/PyRate.py -combLog ../../Results/MBD/species/MBD_scaled_migrants_restricted -tag _KEEP -resample 100 -b 10

# Species-level dataset with scaled predictors + Carnivora and North American herbivore diversities
#python ~/PyRate/PyRate.py -combLog ../../Results/MBD/species/MBD_scaled_Carni -tag _KEEP -resample 100 -b 10

# Time-stratified species-level with scaled predictors
#python  ~/PyRate/PyRate.py -combLog ../../Results/MBD/species/MBD_scaled/early -tag _KEEP -resample 100 -b 10
#python  ~/PyRate/PyRate.py -combLog ../../Results/MBD/species/MBD_scaled/late -tag _KEEP -resample 100 -b 10

# Species-level dataset with scaled predictors and disabling horseshoe prior diversity
#python ~/PyRate/PyRate.py -combLog ../../Results/MBD/species/MBD_scaled_hsp0 -tag _KEEP -resample 100 -b 10

# Species-level dataset with scaled predictors and disabling horseshoe prior + Carnivora diversity
#python ~/PyRate/PyRate.py -combLog ../../Results/MBD/species/MBD_scaled_hsp0_Carni -tag _KEEP -resample 100 -b 10

# Time-stratified species-level with scaled predictors and gamma prior
#python  ~/PyRate/PyRate.py -combLog ../../Results/MBD/species/MBD_scaled_hsp0/early -tag _KEEP -resample 100 -b 10
#python  ~/PyRate/PyRate.py -combLog ../../Results/MBD/species/MBD_scaled_hsp0/late -tag _KEEP -resample 100 -b 10

# Species extant extended (gamma prior)
#python  ~/PyRate/PyRate.py -combLog ../../Results/MBD/species_extant_extended -tag _KEEP -resample 100 -b 10

# Species extant extended (gamma prior) − unphased predictors
#python  ~/PyRate/PyRate.py -combLog ../../Results/MBD/unphased/MBD_scaled_unphased_hsp0 -tag _KEEP -resample 100 -b 10

# Species extant extended − unphased predictors
#python  ~/PyRate/PyRate.py -combLog ../../Results/MBD/unphased/MBD_scaled_unphased -tag _KEEP -resample 100 -b 10

# Species extant extended − unphased predictors
python  ~/PyRate/PyRate.py -combLog ../../Results/MBD/species_rmDD -tag _KEEP -resample 100 -b 10