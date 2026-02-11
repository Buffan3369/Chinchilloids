#!/bin/bash

# Species-level dataset
#python ~/PyRate/PyRate.py -combLog ../../Results/MBD/species -tag _KEEP -resample 100 -b 10

# Species-level dataset with scaled predictors
#python ~/PyRate/PyRate.py -combLog ../../Results/MBD_scaled -tag _KEEP -resample 100 -b 10

# Species-level dataset with scaled predictors + Carnivora and North American herbivore diversities
#python ~/PyRate/PyRate.py -combLog ../../Results/MBD_scaled_migrants -tag _KEEP -resample 100 -b 10

# Species-level dataset with scaled predictors + Carnivora and North American herbivore diversities (temporally unextended)
#python ~/PyRate/PyRate.py -combLog ../../Results/MBD_scaled_migrants_restricted -tag _KEEP -resample 100 -b 10

# Species-level dataset with scaled predictors + Carnivora and North American herbivore diversities
python ~/PyRate/PyRate.py -combLog ../../Results/MBD_scaled_Carni -tag _KEEP -resample 100 -b 10