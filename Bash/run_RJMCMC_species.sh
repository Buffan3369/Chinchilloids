#!/bin/bash

## RJMCMC analyses at the species level
#echo "python3 ~/PyRate/PyRate.py ../RJMCMC/species/1-Full/*_PyRate.py -qShift ../geological_stages.txt -pL 1.1 0 -pM 1.1 0 -pP 2 0 -mG -j \$1 -n 10000000 -s 10000" > tmp_script_species.sh
#/usr/local/bin/parallel -j 20 bash tmp_script_species.sh ::: {1..20}

## Singleton
echo "python3 ~/PyRate/PyRate.py ../RJMCMC/species/2-Singleton/*_PyRate.py -qShift ../geological_stages.txt -pL 1.1 0 -pM 1.1 0 -pP 2 0 -singleton 1 -mG -j \$1 -n 10000000 -s 10000" > tmp_script_species.sh
/usr/local/bin/parallel -j 20 bash tmp_script_species.sh ::: {1..20}

# Without Pleistocene Caribbean taxa (sensitivity)
#echo "python3 ~/PyRate/PyRate.py ../RJMCMC/species/3-NoCaribbea/3-Chinchilloidea_sp_lvl_NoCar_PyRate.py -qShift ../geological_stages.txt -pL 1.1 0 -pM 1.1 0 -pP 2 0 -mG -j \$1 -n 10000000 -s 10000" > tmp_script_species.sh
#/usr/local/bin/parallel -j 20 bash tmp_script_species.sh ::: {1..20}
