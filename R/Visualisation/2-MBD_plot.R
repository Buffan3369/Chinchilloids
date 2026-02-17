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
                       time_facetting = FALSE)
  ggsave(paste0("./Figures/MBD/species_complete", scl, ".pdf"),
         plot = MBD_viol,
         height = 150,
         width = 350,
         units = "mm")
}

## Time-stratified panels ------------------------------------------------------
for(ana in c("_scaled", "_scaled_hsp0")){
  PLOT_DF <- data.frame(param = NA, rate = NA, col = NA, signif_col = NA,
                        value = NA, interval = NA)
  SIGNIF_DF <- data.frame(param = NA, rate = NA, col = NA, max_val = NA,
                          min_val = NA, star_pos = NA, interval = NA)
  for(trt in c("early", "late")){
    int <- ifelse(trt == "early", "38Ma > t > 6Ma", "t < 6Ma")
    rid <- paste0("./Results/MBD/species/MBD", ana, "/", trt)
    tmp <- out_table_MBD(rid, interval = int)
    plot_df <-tmp[[1]]
    signif_df <- tmp[[2]]
    # Extend the big berthas
    PLOT_DF <- rbind.data.frame(PLOT_DF, plot_df)
    SIGNIF_DF <- rbind.data.frame(SIGNIF_DF, signif_df)
  }
  PLOT_DF <- PLOT_DF[-c(1),]
  SIGNIF_DF <- SIGNIF_DF[-c(1),]
  #change Eocene Oligocene order
  PLOT_DF$interval <- factor(PLOT_DF$interval, levels = c("t < 6Ma", "38Ma > t > 6Ma"))
  SIGNIF_DF$interval <- factor(SIGNIF_DF$interval, levels = c("t < 6Ma", "38Ma > t > 6Ma"))
  #plot
  MBD_viol <- MBD.plot(PLOT_DF = PLOT_DF,
                       SIGNIF_DF = SIGNIF_DF,
                       x_breaks = 0:3,
                       x_labels = c(values(covar_idx)),
                       rate.labs = rate.labs,
                       int.labs = c("t < 6Ma", "38Ma > t > 6Ma"))
  ggsave(paste0("./Figures/MBD/species_time_stratified", ana, ".pdf"),
         plot = MBD_viol,
         height = 300,
         width = 400,
         units = "mm")
}
