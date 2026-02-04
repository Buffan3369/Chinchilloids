#!/bin/bash

# Species-level dataset
#python ~/PyRate/PyRate.py -combLog ../../Results/MBD/species -tag _KEEP -resample 100 -b 10

# Species-level dataset with scaled predictors
python ~/PyRate/PyRate.py -combLog ../../Results/MBD_scaled -tag _KEEP -resample 100 -b 10
