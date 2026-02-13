################################################################################
# Name: MBD_plots.r
# Author: Lucas Buffan
# Contact: lucas.l.buffan@gmail.com
# Aim: Summarise posterior MBD param distrib in a table
################################################################################

## Source MBD accessory functions, covar names & other helper f° ---------------
source("./R/useful/MBD_accessory.R")
source("./R/useful/helper_functions.R")  

rid <- paste0("./Results/MBD/species/MBD_scaled_hsp0/")
# 2.5, 50 and 97.5% quantiles for G coefficients
G_post <- get_post(rid, param = "G")
mid_qG <- apply(G_post, MARGIN = 2, FUN = function(x){
  val <- as.numeric(quantile(x, probs = c(0.5)))
  return(round(val, digits = 3))
})
HPD_G <- apply(G_post, MARGIN = 2, FUN = function(x){
  q <- as.numeric(quantile(x, probs = c(0.025, 0.975)))
  return(paste0("[", round(q[1], digits = 3), "; ", round(q[2], digits = 3), "]"))
})
# 2.5, 50 and 97.5% quantiles for W coefficients
W_post <- get_post(rid, param = "W")
mid_qW <- apply(W_post, MARGIN = 2, FUN = function(x){
  val <- as.numeric(quantile(x, probs = c(0.5)))
  return(round(val, digits = 3))
})    
HPD_W <- apply(W_post, MARGIN = 2, FUN = function(x){
  q <- as.numeric(quantile(x, probs = c(0.025, 0.975)))
  return(paste0("[", round(q[1], digits = 3), "; ", round(q[2], digits = 3), "]"))
})
# define covariable dict
CovDict <- covar_idx
N <- length(values(CovDict)) # number of covariables
b <- (N+1)
c <- 2*N #otherwise indexing doesn't work
# merge all
merged <- data.frame(Covar = values(CovDict),
                     G_lamb = mid_qG[1:N],
                     G_lamb_95HPD = HPD_G[1:N],
                     W_G_lamb = mid_qW[1:N],
                     W_G_lamb_95HPD = HPD_W[1:N],
                     G_mu = mid_qG[b:c],
                     G_mu_95HPD = HPD_G[b:c],
                     W_G_mu = mid_qW[b:c],
                     W_G_mu_95HPD = HPD_W[b:c])
# Save
write.table.lucas(merged, "./Figures/MBD/MBD_recap_tbl/Species_scaled_hsp0_MBD_recap_tbl.txt")
