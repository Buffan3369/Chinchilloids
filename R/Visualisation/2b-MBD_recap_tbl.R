################################################################################
# Name: MBD_plots.r
# Author: Lucas Buffan
# Contact: lucas.l.buffan@gmail.com
# Aim: Summarise posterior MBD param distrib in a table
################################################################################

## Source MBD accessory functions, covar names & other helper f° ---------------
source("./R/useful/MBD_accessory.R")
source("./R/useful/helper_functions.R")  

rid <- paste0("./Results/MBD/species_hsp0/")
# 2.5, 50 and 97.5% quantiles for G coefficients
G_post <- get_post(rid, param = "G")
mid_qG <- apply(G_post, MARGIN = 2, FUN = function(x){
  val <- as.numeric(quantile(x, probs = c(0.5)))
  return(round(val, digits = 2))
})
HPD_G <- apply(G_post, MARGIN = 2, FUN = function(x){
  q <- as.numeric(quantile(x, probs = c(0.025, 0.975)))
  return(paste0("[", round(q[1], digits = 2), "; ", round(q[2], digits = 2), "]"))
})
# 2.5, 50 and 97.5% quantiles for W coefficients
W_post <- get_post(rid, param = "W")
mid_qW <- apply(W_post, MARGIN = 2, FUN = function(x){
  val <- as.numeric(quantile(x, probs = c(0.5)))
  return(round(val, digits = 2))
})    
HPD_W <- apply(W_post, MARGIN = 2, FUN = function(x){
  q <- as.numeric(quantile(x, probs = c(0.025, 0.975)))
  return(paste0("[", round(q[1], digits = 2), "; ", round(q[2], digits = 2), "]"))
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
rownames(merged) <- 1:nrow(merged)

merged_sp <- merged %>% 
  select(Covar, G_lamb, G_lamb_95HPD)
merged_ex <- merged %>% 
  select(Covar, G_mu, G_mu_95HPD)
# Save
saveRDS(merged_sp, "./Data/supp_tbl/MBD_recap_tbl/MBD_speciation_recap_tbl.RDS")
saveRDS(merged_ex, "./Data/supp_tbl/MBD_recap_tbl/MBD_extinction_recap_tbl.RDS")
