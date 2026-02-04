#!/bin/bash

# Early
echo "python3 ~/PyRate/PyRate.py -ADE 1 ../ADE/species/early/*_PyRate.py -j \$1 -filter 36 8 -qShift ../geological_stages.txt -n 25000000 -s 25000" > tmp_script_ade_sp.sh
parallel -j 20 bash tmp_script_ade_sp.sh ::: {1..20}

# Late
echo "python3 ~/PyRate/PyRate.py -ADE 1 ../ADE/species/late/*_PyRate.py -j \$1 -filter 8 0 -qShift ../geological_stages.txt -n 25000000 -s 25000" > tmp_script_ade_sp.sh
parallel -j 20 bash tmp_script_ade_sp.sh ::: {1..20}
