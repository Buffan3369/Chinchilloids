################################################################################
# Name: 1abis-Playaround_SpeciesAge.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Simulate occurrences of extant species with little to no fossil 
#              record using divergence times from extant caviomorph phylogeny
#              (https://vertlife.org/).
################################################################################

library(SpeciesAge)
library(treeio)
library(ape)
source("~/Documents/GitHub/CorsaiR/R/1-extract_param_from_PyRate_outputs.R")
source("./R/useful/Poisson_sampling.R")

## 0. Preprocessing ------------------------------------------------------------
nrep <- 20 # Number of replicates

# Extract lambda and mu from PyRate analysis of fossil-only species
# --> Average diversification rate prior 6 Ma (when we detect our shift)
rtt_tbl <- extract_rtt(path = "./Results/RJMCMC/species/7-FossilOnly/combined_logs/RTT_plots.r",
                       ana = "RJMCMC")
lambda <- mean(rtt_tbl$sp_rate[which(rtt_tbl$time > 6 & rtt_tbl$time < 30 )])
mu <- mean(rtt_tbl$ex_rate[which(rtt_tbl$time > 6 & rtt_tbl$time < 30 )])

# Preservation rate table (PyRate fossil-only analysis)
meanQ_tbl <- read.table("./Results/RJMCMC/species/7-FossilOnly/Q_SHIFTS/Parsed_Q_rates.txt",
                        header = T)
q_distribs <- combine_q_distribs(MCMC_path = "./Results/RJMCMC/species/7-FossilOnly/pyrate_mcmc_logs/")

# 95% HPD interval for phylogenetic ages
df_hpd <- read.table("./Data/supp_tbl/95pct_HPD_tbl.txt", header = T)
t_df <- data.frame(t(df_hpd))
colnames(t_df) <- c("min_HPD", "max_HPD")
t_df$species_name <- row.names(t_df)


# for(sp in colnames(df_hpd)){
#   sp_idx <- 
# }
sp <- t_df$species_name[1]

## 1. Sampling a divergence time from phylogeny (v_sp) -------------------------
# The 95% HPD will be approximated to a N(m, sigma²)
min_HPD_sp <- t_df$min_HPD[which(t_df$species_name == sp)]
max_HPD_sp <- t_df$max_HPD[which(t_df$species_name == sp)]
m <- (max_HPD_sp + min_HPD_sp)/2
sigma <- sqrt((max_HPD_sp - mu)/1.96) # = sqrt((max_HPD_sp - min_HPD_sp)/2*1.96)
v_sp <- rnorm(n = 1, mean = mu, sd = sigma)
# Avoid sampling a negative v_sp
while(v_sp < 0){
  v_sp <- rnorm(n = 1, mean = mu, sd = sigma)
}

## 2. Estimate time of speciation of sp (from Calderón del Cid et al. 2024) ----
s_sp <- meanAge(v = v_sp,
                lambda = lambda, 
                mu = mu,
                rho = 1) # assumption of complete extant sampling

## 3. Occurrence sampling following a Poisson Process with piecewise-constant intensity -------
events_sp <- time_varying_sampling(s_sp = s_sp,
                                   meanQ_tbl = meanQ_tbl,
                                   q_distribs = q_distribs)

## 4. Store --------------------------------------------------------------------


a <- noquote(sprintf("%s,", events_sp[1:(length(events_sp)-1)]))
cat(a, events_sp[length(events_sp)])

dat3 <- matrix(data=NA, nrow=length(times), ncol=max(sapply(times, length)))
rownames(dat3) <- taxa

for (p in 1:length(times)){
  dat3[p,1:length(times[[p]])] <- times[[p]]
}

cat(noquote(sprintf("\ndata_%s=[", j)), file=outfile, append=TRUE)

for (n in 1:(length(taxa)-1)){
  rec <- paste(dat3[n,!is.na(dat3[n,])], collapse=",")
  cat(noquote(sprintf("array([%s]),", rec)), file=outfile, append=TRUE, sep="\n")
}
