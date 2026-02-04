#!/bin/bash

    # Getting predictor importance
python3 ~/PyRate/PyRate.py -BDNN_pred_importance ../BDNN/default_arch/combined_logs/combined_20KEEP_mcmc.log -plotBDNN_transf_features ../BDNN_features/Backscale.txt -BDNN_groups '{"Tropicality": ["Tropical", "Extratropical", "Carribbean"]}' -b 0.01 -thread 10 0
    # Getting PDP plots
python3 ~/PyRate/PyRate.py -plotBDNN_effects ../BDNN/default_arch/combined_logs/combined_20KEEP_mcmc.log -plotBDNN_transf_features ../BDNN_features/Backscale.txt -BDNN_groups '{"Tropicality": ["Tropical", "Extratropical", "Carribbean"]}' -b 0.01 -thread 10 0 -resample 100


