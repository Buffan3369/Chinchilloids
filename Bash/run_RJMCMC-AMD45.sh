#!/bin/bash

#################
## GENUS LEVEL ##
#################

# Complete
echo "python3 ~/PyRate/PyRate.py ../RJMCMC/AMD-45/genus/1-Full/*_PyRate.py -qShift ../geological_stages.txt -pL 1.1 0 -pM 1.1 0 -pP 2 0 -mG -j \$1 -n 10000000 -s 10000" > tmp_script.sh
/usr/local/bin/parallel -j 20 bash tmp_script.sh ::: {1..20}

# Without Pleistocene Caribbean taxa
echo "python3 ~/PyRate/PyRate.py ../RJMCMC/AMD-45/genus/3-Spatially_scaled/*_PyRate.py -qShift ../geological_stages.txt -pL 1.1 0 -pM 1.1 0 -pP 2 0 -mG -j \$1 -n 10000000 -s 10000" > tmp_script.sh
/usr/local/bin/parallel -j 20 bash tmp_script.sh ::: {1..20}


###################
## SPECIES LEVEL ##
###################

# Complete
echo "python3 ~/PyRate/PyRate.py ../RJMCMC/AMD-45/species/1-Full/*_PyRate.py -qShift ../geological_stages.txt -pL 1.1 0 -pM 1.1 0 -pP 2 0 -mG -j \$1 -n 10000000 -s 10000" > tmp_script.sh
/usr/local/bin/parallel -j 20 bash tmp_script.sh ::: {1..20}

# Without Pleistocene Caribbean taxa
echo "python3 ~/PyRate/PyRate.py ../RJMCMC/AMD-45/species/3-NoCar/*_PyRate.py -qShift ../geological_stages.txt -pL 1.1 0 -pM 1.1 0 -pP 2 0 -mG -j \$1 -n 10000000 -s 10000" > tmp_script.sh
/usr/local/bin/parallel -j 20 bash tmp_script.sh ::: {1..20}
