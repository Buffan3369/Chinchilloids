################################################################################
# Name: MBD_plots.r
# Author: Lucas Buffan
# Contact: lucas.l.buffan@gmail.com
# Aim: Script for MBD plots (time-stratified)
################################################################################

library(hash)

## Source MBD accessory functions & covar names --------------------------------
source("./R/useful/MBD_accessory.R")

## Set strip labels for plots --------------------------------------------------
rate.labs <- c("Extinction rate", "Origination rate")
names(rate.labs) <- c("Extinction", "Origination")

## Full-time panels ------------------------------------------------------------
for(dir in c("./Results/MBD/species/", 
             "./Results/MBD_scaled/")){
  scl <- NULL
  if(dir == "./Results/MBD_scaled/"){
    scl <- "_scaled"
  }
  int <- NA
  tmp <- out_table_MBD(dir, interval = int)
  plot_df <- tmp[[1]]
  signif_df <- tmp[[2]]
  x_b <- 0:3
  cov_idx <- covar_idx # loaded from MBD_accessory.R
  #plot
  MBD_viol <- MBD.plot(PLOT_DF = plot_df,
                       SIGNIF_DF = signif_df,
                       x_breaks = x_b,
                       x_labels = c(values(cov_idx)),
                       rate.labs = rate.labs,
                       vjust.star.ori = 0.4,
                       vjust.star.ext = 0.4,
                       time_facetting = FALSE)
  ggsave(paste0("./Figures/MBD/species_complete", scl, ".pdf"),
         plot = MBD_viol,
         height = 150,
         width = 350,
         units = "mm")
}