################################################################################
# Name: 3b-Split_TsTe.R
# Author: Lucas Buffan
# Contact: lucas.l.buffan@gmail.com
# Aim: Split TsTe of species from before and after decline.
################################################################################

library(tidyverse)
source("./R/useful/helper_functions.R")

TsTe_tbl <- read.table("./Results/RJMCMC/species/1-Full/LTT/1-Chinchilloidea_sp_lvl_occ_10_Grj_KEEP_se_est.txt",
                       header = T)
## Mean Ts and Te for split ----------------------------------------------------
N <- ncol(TsTe_tbl)
TsTe_tbl_mean <- TsTe_tbl %>% 
  mutate(mean_Ts = apply(X = TsTe_tbl[, seq(3, (N-1), 2)], FUN = mean, na.rm = T, MARGIN = 1),
         mean_Te = apply(X = TsTe_tbl[, seq(4, N, 2)], FUN = mean, na.rm = T, MARGIN = 1)) %>% 
  select(mean_Ts, mean_Te)
## Early -----------------------------------------------------------------------
early_idx <- which(TsTe_tbl_mean$mean_Te > 6)
TsTe_tbl_early <- TsTe_tbl[early_idx, ]
write.table.lucas(TsTe_tbl_early, "./Data/TsTe_stratified/Chinchilloidea_species_TsTe_early.txt")
## Late ------------------------------------------------------------------------
late_idx <- which(TsTe_tbl_mean$mean_Te <= 6)
TsTe_tbl_late <- TsTe_tbl[late_idx, ]
write.table.lucas(TsTe_tbl_late, "./Data/TsTe_stratified/Chinchilloidea_species_TsTe_late.txt")
