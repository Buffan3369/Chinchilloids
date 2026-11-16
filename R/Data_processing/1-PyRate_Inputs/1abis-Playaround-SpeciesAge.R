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

## Playaround ------------------------------------------------------------------

l <- 0.5
v <- runif(n = 1000, min = 0.5, max = 30)

par(mfrow = c(2, 3))
for(m in c(seq(0, 0.4, 0.1), 0.49)){
  s <- sapply(X = v, 
              FUN = function(x){
                meanAge(x, lambda = l, mu = m, rho = 1)
                })
  plot(x = v, y = s, main = paste0("mu: ", m))
  lines(x = 0:50, y = 0:50, lty = "dashed")
}



# Simulate age distribution of a species with branching time = Dinomys' divergence time
age_distrib_Dinomys <- simSpAge(branching_time = v_sp,
                                lambda = l_vsp,
                                mu = m_vsp,
                                reps = 500)

v_chinchilla <- sp_ages$age[which(sp_ages$tip == "Chinchilla_chinchilla")]
age_distrib_chinchilla <- simSpAge(branching_time = v_chinchilla,
                                   lambda = l_vsp,
                                   mu = m_vsp,
                                   reps = 500)

v_lagostomus <- sp_ages$age[which(sp_ages$tip == "Lagostomus_maximus")]
age_distrib_lagostomus <- simSpAge(branching_time = v_lagostomus,
                                   lambda = l_vsp,
                                   mu = m_vsp,
                                   reps = 500)

par(mfrow = c(1,2))

hist(age_distrib_Dinomys, breaks = 20)
hist(age_distrib_lagostomus, breaks = 20)


hist(age_distrib_chinchilla, breaks = 20)



med <- medianAge(v = v_sp,
                 lambda = l_vsp,
                 mu = m_vsp,
                 rho = 1)

mn <- meanAge(v = v_sp,
              lambda = l_vsp,
              mu = m_vsp,
              rho = 1)

par(mfrow = c(1,2))

hist(age_distrib_Dinomys, breaks = 20)
abline(v = med, col = "forestgreen", lty = "dashed")
abline(v = mn, col = "darkred", lty = "dashed")

plot(x= t, y = age_Density_Dinomys, type = "l", xlim = c(0, 21))
points(x = sp_ages$age, y = rep(0, nrow(sp_ages)))
abline(v = med, col = "forestgreen", lty = "dashed")
abline(v = mn, col = "darkred", lty = "dashed")



# if s_sp belongs to an earlier q bin, occurrence sampling will combine multiple time-consecutive exponential distributions (see Silvestro et al. 2019)
# else{
#   
# }


q_rates <- c(0.5, 1, 5, 10)
par(mfrow = c(2, 2))
for(q in q_rates){
  x <- rexp(n = 1000, rate = 1/q)
  hist(x, main = paste0("q = ", q))
}




cavio_tree <- read.mega("./Data/Phylogeny/chinchi_consensus.tree")

chinchi_sp <- c("Chinchilla_chinchilla", "Chinchilla_lanigera", "Lagidium_peruanum",
                "Lagidium_ahuacaense", "Lagidium_viscacia", "Lagidium_wolffsohni",
                "Lagostomus_maximus", "Dinomys_branickii")

chinchi_tree <- ape::keep.tip(cavio_tree@phylo, tip = chinchi_sp)

sp_ages <- calculateTipAges(chinchi_tree) # v table



## 95 HPD boundaries of extant species' divergence times from phylogeny --------
df_hpd <- read.table("./Data/supp_tbl/95pct_HPD_tbl.txt", header = T)

# for(sp in colnames(df_hpd)){
#   sp_idx <- 
# }

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
  # Poisson Point Process: occurrence ages will be given by N_occ_sp independent draws within an exponential distribution of intensity = q_vsp
      # Initialisation
  new_t <- rexp(n = 1,
                rate = q_ssp)
  while(new_t >= s_sp){ # ensure the first sampled time is younger than species' time of origination
    new_t <- rexp(n = 1,
                  rate = q_ssp)
  }
  waiting <- c(new_t)
  cum_T <- new_t
      # Loop
  while(cum_T < s_sp){
    new_t <- rexp(n = 1,
                  rate = q_ssp)
    cum_T <- cum_T + new_t
    waiting <- c(waiting, new_t)
  }
  events <- cumsum(waiting)
      # Drop the last event (occurring before s_sp)
  events <- events[-which(events > s_sp)]
}

