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
rate.labs <- c("Extinction rate", "Speciation rate")
names(rate.labs) <- c("Extinction", "Speciation")

## Full-time panels ------------------------------------------------------------
for(dir in c("./Results/MBD/species/Classical/", 
             "./Results/MBD/species/MBD_scaled/", 
             "./Results/MBD/species/MBD_scaled_migrants/", 
             "./Results/MBD/species/MBD_scaled_migrants_restricted/", 
             "./Results/MBD/species/MBD_scaled_Carni/", 
             "./Results/MBD/species/MBD_scaled_hsp0/", 
             "./Results/MBD/species/MBD_scaled_hsp0_Carni/")){
  scl <- NULL
  x_b <- 0:3
  cov_idx <- covar_idx # loaded from MBD_accessory.R
  if(dir == "./Results/MBD/species/MBD_scaled/"){
    scl <- "_scaled"
  }
  if(dir == "./Results/MBD/species/MBD_scaled_migrants/"){
    scl <- "_scaled_migrants"
    cov_idx <- covar_idx_migrants
    x_b <- 0:5
  }
  if(dir == "./Results/MBD/species/MBD_scaled_migrants_restricted/"){
    scl <- "_scaled_migrants_restricted"
    cov_idx <- covar_idx_migrants
    x_b <- 0:5
  }
  if(dir == "./Results/MBD/species/MBD_scaled_Carni/"){
    scl <- "_scaled_Carnivora"
    cov_idx <- covar_idx_carni
    x_b <- 0:4
  }
  if(dir == "./Results/MBD/species/MBD_scaled_hsp0/"){
    scl <- "_scaled_hsp0"
    cov_idx <- covar_idx
    x_b <- 0:3
  }
  if(dir == "./Results/MBD/species/MBD_scaled_hsp0_Carni/"){
    scl <- "_scaled_hsp0_Carni"
    cov_idx <- covar_idx_carni
    x_b <- 0:4
  }
  int <- NA
  tmp <- out_table_MBD(dir, interval = int)
  plot_df <- tmp[[1]]
  signif_df <- tmp[[2]]
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