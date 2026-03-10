library(psych)

post_MBD1 <- read.table("./Results/MBD/unphased/MBD_scaled_unphased_hsp0/combined_20_KEEP.log", header = T)
lkl_MBD1 <- post_MBD1$likelihood
marg_lkl1 <- harmonic.mean(lkl_MBD1) # Marginal likelihood is approximated by the harmonic mean of the likelihood across MCMC iterations

post_MBD2 <- read.table("./Results/MBD/species/combined_20_KEEP.log", header = T)
lkl_MBD2 <- post_MBD2$likelihood
marg_lkl2 <- harmonic.mean(lkl_MBD2)

post_MBD3 <- read.table("./Results/MBD/unphased/MBD_scaled_unphased/combined_17_KEEP.log", header = T)
lkl_MBD3 <- post_MBD3$likelihood
marg_lkl3 <- harmonic.mean(lkl_MBD3)

post_MBD4 <- read.table("./Results/MBD/species_rmDD/combined_20_KEEP.log", header = T)
lkl_MBD4 <- post_MBD4$likelihood
marg_lkl4 <- harmonic.mean(lkl_MBD4)


## Calculating 2*log(Bayes Factor) matrix
# Vector of approximated marginal likelihoods
LK_vect <- c(marg_lkl1, marg_lkl2, marg_lkl3, marg_lkl4)

BF <- function(i, j){
  return(2*(LK_vect[i] - LK_vect[j]))
}

BF_mat <- matrix(nrow = 4, ncol = 4)
for(i in 1:4){
  BF_mat[i,] <- sapply(X = 1:4, FUN = function(x){return(BF(i, x))})
}

