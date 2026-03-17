################################################################################
# Name: 1d-RTT_per_imputation_replicate.R
# Author: Lucas Buffan (Lucas.L.Buffan@gmail.com)
# Aim: Plot diversification rates through time estimated by BDNN across the 10
#      replicates that we ran after imputation of missing traits. 
################################################################################

library(ggpubr)
library(tidyverse)
library(cowplot)

## Source accessory functions for plotting -------------------------------------
source("~/Documents/GitHub/CorsaiR/R/1-extract_param_from_PyRate_outputs.R")
source("~/Documents/GitHub/CorsaiR/R/2-plotting_facilities.R")
source("./R/useful/helper_functions.R")
source("./R/useful/load_GTS.R")

gsc1$max_age[nrow(gsc1)] <- 35
gsc1$name[which(gsc1$name == "Eocene")] <- ""
gsc1$name[which(gsc1$name == "Pliocene")] <- "Plio"
gsc1$name[which(gsc1$name == "Pleistocene")] <- "Ple"
gsc4 <- gsc4[-nrow(gsc4), ]
gsc4$max_age[nrow(gsc4)] <- 35

plotlist <- list()
## BDNN RTT --------------------------------------------------------------------
j <- 0
for(i in 1:10){
  path_to_BDNN <- list.files(paste0("./Results/BDNN/BDNN_imputation_NoCar/Replicate_", i, "/combined_logs/"),
                             pattern = "_RTT.r", full.names = T)[[1]]
  rtt_bdnn <- extract_rtt(path_to_BDNN, ana = "BDNN")
  rtt_bdnn$time[which(rtt_bdnn$time == 
                        max(rtt_bdnn$time))] <- 35 # harmonise x scale between replicates
  if(i %in% c(5, 10)){
    # Display GTS
    sp_bd <- rtt_plot(rtt_bdnn, type = "sp",
                      restrict_y = F, 
                      plot_bdnn = T, 
                      stage_x_breaks = F, 
                      lwd = 0.3,
                      manual_x_breaks = seq(0, 30, 5),
                      display_OliNeo = T,
                      y_limits = c(0, 1.3),
                      y_breaks = seq(0, 1.2, 0.3),
                      x_lab = "Time (Ma)",
                      y_lab = "",
                      main = paste0("Speciation rate (r.", i, ")"),
                      main.size = 15,
                      axes.labelsize = 10,
                      ticks.labelsize = 6,
                      ticks.lwd = 0.25,
                      several_gts = TRUE,
                      geoscale = gsc1,
                      geoscale2 = gsc4,
                      abbr = list(TRUE, FALSE),
                      geoscale_height = unit(0.5, "line"),
                      geoscale_labelsize = list(1, 2),
                      geoscale_lwd = 0.1,
                      panel_border_lwd = 0.1)
    
    ex_bd <- rtt_plot(rtt_bdnn, type = "ex",
                      restrict_y = F, 
                      plot_bdnn = T, 
                      stage_x_breaks = F, 
                      lwd = 0.3,
                      manual_x_breaks = seq(0, 30, 5),
                      display_OliNeo = T,
                      y_limits = c(0, 1.3),
                      y_breaks = seq(0, 1.2, 0.3),
                      x_lab = "Time (Ma)",
                      y_lab = "",
                      main = paste0("Extinction rate (r.", i, ")"),
                      main.size = 15,
                      axes.labelsize = 10,
                      ticks.labelsize = 6,
                      ticks.lwd = 0.25,
                      several_gts = TRUE,
                      geoscale = gsc1,
                      geoscale2 = gsc4,
                      abbr = list(TRUE, FALSE),
                      geoscale_height = unit(0.5, "line"),
                      geoscale_labelsize = list(1, 2),
                      geoscale_lwd = 0.1,
                      panel_border_lwd = 0.1)
    
  }
  else{
    sp_bd <- rtt_plot(rtt_bdnn, type = "sp",
                      restrict_y = F, 
                      plot_bdnn = T,
                      display_OliNeo = T,
                      lwd = 0.3,
                      y_limits = c(0, 1.3),
                      y_breaks = seq(0, 1.2, 0.3),
                      x.axis = F,
                      display_gts = F,
                      x_lab = "",
                      y_lab = "",
                      main = paste0("Speciation rate (r.", i, ")"),
                      main.size = 15,
                      axes.labelsize = 10,
                      ticks.labelsize = 6,
                      ticks.lwd = 0.25,
                      panel_border_lwd = 0.1)
    
    ex_bd <- rtt_plot(rtt_bdnn, type = "ex",
                      restrict_y = F, 
                      plot_bdnn = T, 
                      stage_x_breaks = F, 
                      lwd = 0.3,
                      manual_x_breaks = seq(0, 30, 5),
                      display_OliNeo = T,
                      x.axis = F,
                      y_limits = c(0, 1.3),
                      y_breaks = seq(0, 1.2, 0.3),
                      x_lab = "",
                      y_lab = "",
                      main = paste0("Extinction rate (r.", i, ")"),
                      main.size = 15,
                      axes.labelsize = 10,
                      ticks.labelsize = 6,
                      ticks.lwd = 0.25,
                      display_gts = F,
                      panel_border_lwd = 0.1)
  }
  plotlist[[i+j]] <- sp_bd
  j <- j+1
  plotlist[[i+j]] <- ex_bd
}

## Arrange ---------------------------------------------------------------------
# From replicate 1 to 5
full_plot15 <- ggarrange(plotlist = plotlist[1:10], ncol = 2, nrow = 5, heights = c(1,1,1,1,1.3))
ggsave("./Figures/Supp/RTT_imputation/RTT_imput_full_NoCar15.pdf", full_plot15,
       height = 200, width = 150, units = "mm")

# From replicate 6 to 10
full_plot610 <- ggarrange(plotlist = plotlist[11:20], ncol = 2, nrow = 5, heights = c(1,1,1,1,1.3))
ggsave("./Figures/Supp/RTT_imputation/RTT_imput_full_NoCar610.pdf", full_plot610,
       height = 200, width = 150, units = "mm")

