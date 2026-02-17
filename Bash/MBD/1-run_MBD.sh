#!/bin/bash

## Genus-level
#echo "python3 ~/PyRate/PyRateMBD.py -d ../MBD/genus/*se_est.txt -var ../MBD_predictors/ -j \$1 -n 5000000 -s 5000" > tmp_script_MBD.sh
#parallel -j 15 bash tmp_script_MBD.sh ::: {0..14}

## Species-level
#echo "python3 ~/PyRate/PyRateMBD.py -d ../MBD/species/*se_est.txt -var ../MBD_predictors/ -j \$1 -n 5000000 -s 5000" > tmp_script_MBD.sh
#parallel -j 18 bash tmp_script_MBD.sh ::: {0..17}

## Species-level scaled
#echo "python3 ~/PyRate/PyRateMBD.py -d ../MBD_scaled/*se_est.txt -var ../MBD_predictors_Scaled/ -j \$1 -n 5000000 -s 5000" > tmp_script_MBD.sh
#parallel -j 18 bash tmp_script_MBD.sh ::: {0..17}

## Species-level time-stratified hsp 0
#EARLY
#echo "python3 ~/PyRate/PyRateMBD.py -d ../MBD_scaled_hsp0/early/Chinchilloidea_species_TsTe_early.txt -var ../MBD_predictors_Scaled/early -hsp 0 -j \$1 -n 5000000 -s 5000" > tmp_script_MBD.sh
#parallel -j 18 bash tmp_script_MBD.sh ::: {0..17}

# LATE
#echo "python3 ~/PyRate/PyRateMBD.py -d ../MBD_scaled_hsp0/late/Chinchilloidea_species_TsTe_late.txt -var ../MBD_predictors_Scaled/late -hsp 0 -j \$1 -n 5000000 -s 5000" > tmp_script_MBD.sh
#parallel -j 18 bash tmp_script_MBD.sh ::: {0..17}

## Species-level time-stratified
#EARLY
echo "python3 ~/PyRate/PyRateMBD.py -d ../MBD_scaled/early/Chinchilloidea_species_TsTe_early.txt -var ../MBD_predictors_Scaled/early -j \$1 -n 5000000 -s 5000" > tmp_script_MBD.sh
parallel -j 18 bash tmp_script_MBD.sh ::: {0..17}

# LATE
echo "python3 ~/PyRate/PyRateMBD.py -d ../MBD_scaled/late/Chinchilloidea_species_TsTe_late.txt -var ../MBD_predictors_Scaled/late -j \$1 -n 5000000 -s 5000" > tmp_script_MBD.sh
parallel -j 18 bash tmp_script_MBD.sh ::: {0..17}


rm tmp_script_MBD.sh
