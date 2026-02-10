#!/bin/bash

echo "python3 ~/PyRate/PyRate.py ../RJMCMC/Northern_Herbivores/*_PyRate.py -qShift ../geological_stages.txt -pL 1.1 0 -pM 1.1 0 -pP 2 0 -mG -j \$1 -n 5000000 -s 5000" > tmp_script_NH.sh
/usr/local/bin/parallel -j 10 bash tmp_script_NH.sh ::: {1..10}
