#!/bin/bash

# Species-level dataset
#python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD/species/Classical -ana "MBD"

# Species-level with scaled predictors
#python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD/species/MBD_scaled -ana "MBD"

# Species-level with scaled predictors + Carnivora and NA herbivore diversity
#python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD/species/MBD_scaled_migrants -ana "MBD"

# Species-level with scaled predictors + Carnivora and NA herbivore diversity (temporally unextended)
#python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD/species/MBD_scaled_migrants_restricted -ana "MBD"

# Species-level with scaled predictors + Carnivora diversity
#python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD/species/MBD_scaled_Carni -ana "MBD"

# Time-stratified species-level with scaled predictors
# python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD/species/MBD_scaled/early -ana "MBD"
# python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD/species/MBD_scaled/late -ana "MBD"

# Species-level with scaled predictors and gamma prior
#python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD/species/MBD_scaled_hsp0 -ana "MBD"

# Species-level with scaled predictors and gamma prior + Carnivora diversity
#python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD/species/MBD_scaled_hsp0_Carni -ana "MBD"

# Time-stratified species-level with scaled predictors and gamma prior
#python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD/species/MBD_scaled_hsp0/early -ana "MBD"
#python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD/species/MBD_scaled_hsp0/late -ana "MBD"

# Species extant extended (gamma prior)
python ~/Documents/GitHub/CorsaiR/Python/assess_run_convergence.py -dir ../../Results/MBD/species_extant_extended -ana "MBD"