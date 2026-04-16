#!/bin/bash

#########################################################
## ------------------ Species-level ------------------ ##
#########################################################

# Diversity & Diversification
for pth in 1-Full 2-Singleton 3-NoCaribbea
do
	#Combine log files for runs that converged
	python ~/PyRate/PyRate.py -combLogRJ ../Results/RJMCMC/species/$pth/pyrate_mcmc_logs -tag KEEP -b 10 -resample 100
	mkdir -p ../Results/RJMCMC/species/$pth/combined_logs
	mv ../Results/RJMCMC/species/$pth/pyrate_mcmc_logs/combined_* ../Results/RJMCMC/species/$pth/combined_logs
	#Plot RTT
	python ~/PyRate/PyRate.py -plotRJ ../Results/RJMCMC/species/$pth/combined_logs -b 10
	Rscript ../Results/RJMCMC/species/$pth/combined_logs/RTT_plots.r
	#Plot LTT
	mkdir -p ../Results/RJMCMC/species/$pth/LTT/
	python ~/PyRate/PyRate.py -ginput ../Results/RJMCMC/species/$pth/pyrate_mcmc_logs -tag KEEP_ -b 10
	mv ../Results/RJMCMC/species/$pth/pyrate_mcmc_logs/*_se_est.txt ../Results/RJMCMC/species/$pth/LTT/
	mv ../Results/RJMCMC/species/$pth/combined_logs/*_LTT.r ../Results/RJMCMC/species/$pth/LTT/
	#Diversity-through-time (median, min and max diversity)
	python ~/PyRate/PyRate.py -d ../Results/RJMCMC/species/$pth/LTT/*_se_est.txt -ltt 1
done

# Diversification only
# for pth in 4-Tropical 5-Extratropical
# do
# 	#Combine log files for runs that converged
# 	python ~/PyRate/PyRate.py -combLog ../Results/RJMCMC/species/$pth/pyrate_mcmc_logs -tag KEEP_Grj_mcmc -b 10 -resample 100
# 	python ~/PyRate/PyRate.py -combLog ../Results/RJMCMC/species/$pth/pyrate_mcmc_logs -tag KEEP_Grj_sp_rates -b 10 -resample 100
# 	python ~/PyRate/PyRate.py -combLog ../Results/RJMCMC/species/$pth/pyrate_mcmc_logs -tag KEEP_Grj_ex_rates -b 10 -resample 100
# 	mkdir -p ../Results/RJMCMC/species/$pth/combined_logs
# 	mv ../Results/RJMCMC/species/$pth/pyrate_mcmc_logs/combined_* ../Results/RJMCMC/species/$pth/combined_logs
# 	#Plot RTT
# 	python ~/PyRate/PyRate.py -plotRJ ../Results/RJMCMC/species/$pth/combined_logs -b 10
# 	Rscript ../Results/RJMCMC/species/$pth/combined_logs/RTT_plots.r
# done

# for cat in XS S M L XL XXL
# do
# 	#Combine log files for runs that converged
# 	python ~/PyRate/PyRate.py -combLog ../Results/RJMCMC/species/6-BM_categories/$cat/pyrate_mcmc_logs -tag KEEP_Grj_mcmc -b 10 -resample 100
# 	python ~/PyRate/PyRate.py -combLog ../Results/RJMCMC/species/6-BM_categories/$cat/pyrate_mcmc_logs -tag KEEP_Grj_sp_rates -b 10 -resample 100
# 	python ~/PyRate/PyRate.py -combLog ../Results/RJMCMC/species/6-BM_categories/$cat/pyrate_mcmc_logs -tag KEEP_Grj_ex_rates -b 10 -resample 100
# 	mkdir -p ../Results/RJMCMC/species/6-BM_categories/$cat/combined_logs
# 	mv ../Results/RJMCMC/species/6-BM_categories/$cat/pyrate_mcmc_logs/combined_* ../Results/RJMCMC/species/6-BM_categories/$cat/combined_logs
# 	#Plot RTT
# 	python ~/PyRate/PyRate.py -plotRJ ../Results/RJMCMC/species/6-BM_categories/$cat/combined_logs -b 10
# 	Rscript ../Results/RJMCMC/species/6-BM_categories/$cat/combined_logs/RTT_plots.r
# done

#######################################################
## ------------------ Genus-level ------------------ ##
#######################################################

# for pth in 1-Full 2-Singleton 3-Spatially_scaled
# do
# 	#Combine log files for runs that converged
# 	python ~/PyRate/PyRate.py -combLogRJ ../Results/RJMCMC/genus/$pth/pyrate_mcmc_logs -tag KEEP -b 10 -resample 100
# 	mkdir -p ../Results/RJMCMC/genus/$pth/combined_logs
# 	mv ../Results/RJMCMC/genus/$pth/pyrate_mcmc_logs/combined_* ../Results/RJMCMC/genus/$pth/combined_logs
# 	#Plot RTT
# 	python ~/PyRate/PyRate.py -plotRJ ../Results/RJMCMC/genus/$pth/combined_logs -b 10
# 	Rscript ../Results/RJMCMC/genus/$pth/combined_logs/RTT_plots.r
# 	#Plot LTT
# 	mkdir -p ../Results/RJMCMC/genus/$pth/LTT/
# 	python ~/PyRate/PyRate.py -ginput ../Results/RJMCMC/genus/$pth/pyrate_mcmc_logs -tag KEEP_ -b 10
# 	mv ../Results/RJMCMC/genus/$pth/pyrate_mcmc_logs/*_se_est.txt ../Results/RJMCMC/genus/$pth/LTT/
# 	mv ../Results/RJMCMC/genus/$pth/combined_logs/*_LTT.r ../Results/RJMCMC/genus/$pth/LTT/
# 	#Diversity-through-time (median, min and max diversity)
# 	python ~/PyRate/PyRate.py -d ../Results/RJMCMC/genus/$pth/LTT/*_se_est.txt -ltt 1
# done


