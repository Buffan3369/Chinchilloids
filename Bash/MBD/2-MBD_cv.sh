#!/bin/bash

# Species-level dataset
#python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD/species -ana "MBD"

# Species-level with scaled predictors
#python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD_scaled -ana "MBD"

# Species-level with scaled predictors + Carnivora and NA herbivore diversity
#python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD_scaled_migrants -ana "MBD"

# Species-level with scaled predictors + Carnivora and NA herbivore diversity (temporally unextended)
#python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD_scaled_migrants_restricted -ana "MBD"

# Species-level with scaled predictors + Carnivora diversity
python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD_scaled_Carni -ana "MBD"