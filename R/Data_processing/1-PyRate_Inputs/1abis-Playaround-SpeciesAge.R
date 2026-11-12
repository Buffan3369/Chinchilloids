################################################################################
# Name: 1abis-Playaround_SpeciesAge.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Simulate occurrences of extant species with little to no fossil 
#              record using divergence times from extant caviomorph phylogeny
#              (https://vertlife.org/).
################################################################################

library(SpeciesAge)
source("~/Documents/GitHub/CorsaiR/R/1-extract_param_from_PyRate_outputs.R")

## Playaround ------------------------------------------------------------------

# t <- seq(0.1, 10, 0.1)
# 
# mean_Ts <- sapply(X = t, 
#              FUN = function(x){meanAge(v = x, lambda = 0.4, mu = 0.3)})
# 
# median_Ts <- sapply(X = t,
#                     FUN = function(x){medianAge(v = x, lambda = 0.4, mu = 0.3, rho = 1)})
# 
# 
# par(mfrow = c(2,2))
# plot(x = t, y = mean_Ts, type = "l", xlab = "Td_phylo", ylab = "mean_Ts")
# plot(x = t, y = median_Ts, type = "l", xlab = "Td_phylo", ylab = "median_Ts")
# plot(x = mean_Ts, y = median_Ts, type = "l", xlab = "mean_Ts", ylab = "median_Ts")
# lines(x = 0:3, y = 0:3, col = "red")
# dev.off()
# 
# T_si <- meanAge(v = 4, lambda = 0.4, mu = 0.3)
# 
# q <- 2.2
# 
# # Number of sampled occ follows a poisson law of intensity q*T_si
# N_occ <- rpois(n = 1, lambda = q*T_si)
# 
# # Homogeneous poisson process
# rexp(n = 2*N_occ, 1/q)

## 95 HPD boundaries of extant species' divergence times from phylogeny --------
df_hpd <- read.table("./Data/supp_tbl/95pct_HPD_tbl.txt", header = T)

# Sampling a divergence time from phylogeny (v_sp)
# The 95% HPD will be approximated to a N(mu, sigma²)
min_HPD <- df_hpd[1,3]
max_HPD <- df_hpd[2,3]
mu <- (max_HPD + min_HPD)/2
sigma <- sqrt((max_HPD - mu)/1.96) # = sqrt((max_HPD - min_HPD)/2*1.96)
v_sp <- rnorm(n = 1, mean = mu, sd = sigma)

# Extract lambda(t), mu(t) and q(t) from PyRate analysis of fossil-only species
rtt_tbl <- extract_rtt(path = "./Results/RJMCMC/species/7-FossilOnly/combined_logs/RTT_plots.r",
                       ana = "RJMCMC")
q_tbl <- read.table("./Results/RJMCMC/species/7-FossilOnly/Q_SHIFTS/Parsed_Q_rates.txt", header = T)

# Get lambda(v_sp), mu(v_sp)
corr_idx_rtt <- which.min(sapply(X = rtt_tbl$time, 
                                 FUN = function(x){abs(x - v_sp)}))
l_vsp <- rtt_tbl$sp_rate[corr_idx_rtt]
m_vsp <- rtt_tbl$ex_rate[corr_idx_rtt]

## Estimated time of speciation of sp (from Calderón del Cid et al. 2024) ------
s_sp <- meanAge(v = v_sp,
                lambda = l_vsp, 
                mu = m_vsp,
                rho = 1) # assumption of complete extant sampling

## Occurrence sampling following a piecewise-constant Poisson process ----------
# Get all the q_rates from s_sp to present
diff_tq <- q_tbl$Age - s_sp
# if all differences are positive, this means that s_sp belongs to the last q bin
if(length(unique(sign(diff_tq))) == 1){
  q_ssp <- q_tbl$mean_Q[nrow(q_tbl)]
  # Number of sampled occurrences per q interval
  #N_occ_sp <- rpois(n = 1, lambda = q_ssp*s_sp)
  # Poisson Point Process: occurrence ages will be given by N_occ_sp independent draws within an exponential distribution of intensity = 1/(q_vsp*s_sp)
      # Initialisation
  new_t <- rexp(n = 1,
                rate = 1/q_ssp)
  while(new_t >= s_sp){ # ensure the first sampled time is younger than species' time of origination
    new_t <- rexp(n = 1,
                  rate = 1/q_ssp)
  }
  waiting <- c(new_t)
  cum_T <- new_t
      # Loop
  while(cum_T < s_sp){
    new_t <- rexp(n = 1,
                  rate = 1/q_ssp)
    cum_T <- cum_T + new_t
    waiting <- c(waiting, new_t)
  }
  events <- cumsum(waiting)
      # Drop the last event (occurring before s_sp)
  events <- events[-which(events > s_sp)]
}


# if s_sp belongs to an earlier q bin, occurrence sampling will combine multiple time-consecutive exponential distributions (see Silvestro et al. 2019)
# else{
#   
# }
