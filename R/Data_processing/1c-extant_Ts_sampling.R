################################################################################
# Name: 1c-extant_Ts_sampling.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Simulate occurrences of extant species with little to no fossil 
#              record using divergence times from extant caviomorph phylogeny
#              (https://vertlife.org/)
################################################################################

library(treeio)
library(tidytree)
library(hash)

source("./R/useful/helper_functions.R")

## Extract info from phylogeny -------------------------------------------------
# Caviomorph tree from VertLife
cavio_tree <- read.mega("./Data/Phylogeny/chinchi_consensus.tree")

chinchi_sp <- c("Chinchilla_chinchilla", "Chinchilla_lanigera", "Lagidium_peruanum",
                "Lagidium_ahuacaense", "Lagidium_viscacia", "Lagidium_wolffsohni",
                "Lagostomus_maximus", "Dinomys_branickii")

chinchi_tree <- keep.tip(cavio_tree, tip = chinchi_sp)

# Get the boundaries of the 95%HPD of Ts distribs for species lacking fossil record
dinomys_hpd <- chinchi_tree@data$CAheight_0.95_HPD[[9]]
chinchilla_hpd <- chinchi_tree@data$CAheight_0.95_HPD[[12]]
ahuacaense_hpd <- chinchi_tree@data$CAheight_0.95_HPD[[13]]
viscacia_hpd <- chinchi_tree@data$CAheight_0.95_HPD[[15]]

# Create dictionnary
dict_hpd <- hash("Dinomys_branickii" = dinomys_hpd,
                 "Chinchilla_chinchilla" = chinchilla_hpd,
                 "Chinchilla_lanigera" = chinchilla_hpd,
                 "Lagidium_ahuacaense" = ahuacaense_hpd,
                 "Lagidium_viscacia" = viscacia_hpd,
                 "Lagidium_wolffsohni" = viscacia_hpd)

## Sampling scheme using truncated exponential distributions -------------------
# Rate of an exponential distribution with a given proportion of the distribution (`thr`) lying between 0 and Ts
sampling_rate <- function(thr = 0.95, Ts){
  lambda <- -(log(1 - thr)) / Ts
  return(lambda)
}

# Dummy truncated exponential distribution (truncation threshold: Ts)
# Artificically increases the probability of sampling close to Ts
trunc_exp <- function(n, lambda, Ts){
  truc_exp_vect <- c()
  for(i in 1:n){
    r <- rexp(n = 1, rate = lambda)
    # repeat until we don't cross Ts
    while(r > Ts){
      r <- rexp(n = 1, rate = lambda)
    }
    truc_exp_vect <- c(truc_exp_vect, r)
  }
  return(truc_exp_vect)
}

occtbl_exp <- data.frame(Species = c(rep("Dinomys_branickii", 10),
                                     rep("Chinchilla_chinchilla", 10),
                                     rep("Chinchilla_lanigera", 10),
                                     rep("Lagidium_viscacia", 10),
                                     rep("Lagidium_wolffsohni", 10)),
                         Status = "extant",
                         min_age = NA,
                         max_age = NA)

for(sp in c("Dinomys_branickii", "Chinchilla_chinchilla", "Chinchilla_lanigera", 
            "Lagidium_viscacia", "Lagidium_wolffsohni")){
  # Initialise min and max_age vectors
  min_ages <- c()
  max_ages <- c()
  # Lower and upper bound of the corresponding 95% HPD
  min_HPD <- values(dict_hpd[sp])[1]
  max_HPD <- values(dict_hpd[sp])[2]
  # The 95% HPD will be approximated to a (symmetrical) N(mu, sigma²)
  mu <- (max_HPD + min_HPD)/2
  sigma <- sqrt((max_HPD - mu)/1.96) # = sqrt((max_HPD - min_HPD)/2*1.96)
  # Assign proportion of truc_expo within [Ts, 0]
  alpha <- ifelse(sp == "Dinomys_branickii", 0.999, 0.5)
  for(i in 1:10){
    # Sampling a Ts value
    Ts <- rnorm(n = 1, mean = mu, sd = sigma)
    # Sampling an occurrence min and max_age from a truncated exponential distribution
    lamb <- sampling_rate(thr = alpha, Ts = Ts)
    ages <- trunc_exp(n = 2, lambda = lamb, Ts = Ts)
    min_ages <- c(min_ages, ages[which.min(ages)])
    max_ages <- c(max_ages, ages[which.max(ages)])
  }
  occtbl_exp$min_age[which(occtbl_exp$Species == sp)] <- min_ages
  occtbl_exp$max_age[which(occtbl_exp$Species == sp)] <- max_ages
}

# Save
write.table.lucas(occtbl_exp, "./Data/OccDB_cleaned/extant_taxa_with_no_fossils.txt")
