#!/bin/bash

for s in species genus
do
	#Combine logs
	python ~/PyRate/PyRate.py -combLog ../../Results/BDCS/$s/pyrate_mcmc_logs -tag mcmc -b 10
	python ~/PyRate/PyRate.py -combLog ../../Results/BDCS/$s/pyrate_mcmc_logs -tag marginal_rates -b 10
	mkdir -p ../../Results/BDCS/$s/combined_logs
	mv ../../Results/BDCS/$s/pyrate_mcmc_logs/combined_* ../../Results/BDCS/$s/combined_logs
	#Plot RTT
	python ~/PyRate/PyRate.py -plot2 ../../Results/BDCS/$s/combined_logs -b 10
done