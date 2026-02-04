#!/bin/bash

## Default architecture (2 layers with 16 and 8 nodes)
echo "python3 ~/PyRate/PyRate.py ../BDNN_Traits/*_PyRate.py -BDNNmodel 1 -trait_file ../BDNN_features/Categorical_traits_NoNA.txt -BDNNtimevar ../BDNN_features/Continuous_correlates.txt -j \$1 -mG -qShift ../geological_stages.txt -n 50000000 -s 50000" > tmp_script_bdnn.sh
/usr/local/bin/parallel -j 20 bash tmp_script_bdnn.sh ::: {1..20}

## Alternative architecture (3 layers, 20, 10 and 5, nodes, 75M iterations)
#echo "python3 ~/PyRate/PyRate.py ../BDNN/alt_arch/*_PyRate.py -BDNNmodel 1 -BDNNnodes 20 10 5 -trait_file ../BDNN_features/Categorical_traits_truncated.txt -BDNNtimevar ../BDNN_features/Continuous_correlates.txt -j \$1 -mG -qShift ../geological_stages.txt -n 50000000 -s 50000" > tmp_script_bdnn.sh
#/usr/local/bin/parallel -j 20 bash tmp_script_bdnn.sh ::: {1..20}

