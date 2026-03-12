################################################################################
# Name: 1a-Diversification.R
# Author: Lucas Buffan (Lucas.L.Buffan@gmail.com)
# Aim: Plot diversification rates through time estimated by different models
################################################################################

library(ggpubr)
library(tidyverse)
library(cowplot)

## Source accessory functions for plotting -------------------------------------
source("~/Documents/GitHub/CorsaiR/R/1-extract_param_from_PyRate_outputs.R")
source("~/Documents/GitHub/CorsaiR/R/2-plotting_facilities.R")
source("./R/useful/helper_functions.R")
source("./R/useful/load_GTS.R")

## RJMCMC RTT ------------------------------------------------------------------
path_to_rj_RTT <- "./Results/RJMCMC/species/1-Full/combined_logs/RTT_plots.r"
rtt_rj <- extract_rtt(path_to_rj_RTT, ana = "RJMCMC")

gsc1$max_age[nrow(gsc1)] <- max(rtt_rj$time)
gsc1$name[which(gsc1$name == "Eocene")] <- ""
gsc1$name[which(gsc1$name == "Pliocene")] <- "Plio"
gsc1$name[which(gsc1$name == "Pleistocene")] <- "Ple"
gsc4 <- gsc4[-nrow(gsc4), ]
gsc4$max_age[nrow(gsc4)] <- max(rtt_rj$time)
sp_rj <- rtt_plot(rtt_rj, type = "sp",
                  restrict_y = F, 
                  display_OliNeo = T,
                  lwd = 0.3,
                  y_limits = c(0, 5.3),
                  y_breaks = seq(0, 5, 0.5),
                  x.axis = F,
                  display_gts = F,
                  y_lab = "Speciation rate",
                  main = "rjMCMC",
                  main.size = 15,
                  axes.labelsize = 10,
                  ticks.labelsize = 6,
                  ticks.lwd = 0.25,
                  panel_border_lwd = 0.1) +
  annotate(geom = "text", label = "*", x = 2, y = 4.5, size = 6, colour = "#4c4cec")

ex_rj <- rtt_plot(rtt_rj, type = "ex",
                  restrict_y = F,
                  stage_x_breaks = F, 
                  manual_x_breaks = seq(0, 30, 5),
                  display_OliNeo = T,
                  lwd = 0.3,
                  y_limits = c(0, 3.52),
                  y_breaks = seq(0, 3, 0.5),
                  several_gts = TRUE,
                  y_lab = "Extinction rate",
                  geoscale = gsc1,
                  geoscale2 = gsc4,
                  geoscale_height = unit(0.5, "line"),
                  abbr = list(TRUE, FALSE),
                  axes.labelsize = 10,
                  ticks.labelsize = 6,
                  ticks.lwd = 0.25,
                  geoscale_labelsize = list(1, 2),
                  geoscale_lwd = 0.1,
                  panel_border_lwd = 0.1) +
  annotate(geom = "text", label = "*", x = 6, y = 2, size = 6, colour = "#e34a33")

## BDNN RTT --------------------------------------------------------------------
path_to_BDNN <- "./Results/BDNN/BM_6cat/combined_20KEEP_RTT.r"
rtt_bdnn <- extract_rtt(path_to_BDNN, ana = "BDNN")
rtt_bdnn$time[which(rtt_bdnn$time == 
                      max(rtt_bdnn$time))] <- max(rtt_rj$time) # harmonise x scale

sp_bd <- rtt_plot(rtt_bdnn, type = "sp",
                  restrict_y = F, 
                  plot_bdnn = T,
                  display_OliNeo = T,
                  lwd = 0.3,
                  y_limits = c(0, 5.3),
                  y_breaks = seq(0, 5, 0.5),
                  x.axis = F,
                  display_gts = F,
                  y_lab = "",
                  main = "BDNN",
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
                  y_limits = c(0, 3.52),
                  y_breaks = seq(0, 3, 0.5),
                  several_gts = TRUE,
                  geoscale = gsc1,
                  geoscale2 = gsc4,
                  geoscale_height = unit(0.5, "line"),
                  abbr = list(TRUE, FALSE),
                  y_lab = "",
                  axes.labelsize = 10,
                  ticks.labelsize = 6,
                  ticks.lwd = 0.25,
                  geoscale_labelsize = list(1, 2),
                  geoscale_lwd = 0.1,
                  panel_border_lwd = 0.1)

## MBD RTT ---------------------------------------------------------------------
path_to_mbd_RTT <- "./Results/MBD/species/MBD_scaled_hsp0/combined_18_KEEP_RTT.r"
rtt_mbd <- extract_rtt(path_to_mbd_RTT, ana = "MBD")
# harmonise timescale with the two others
rtt_mbd <- rtt_mbd %>% filter(time <= max(rtt_rj$time))

sp_mbd <- rtt_plot(rtt_mbd, type = "sp",
                   restrict_y = F,
                   display_OliNeo = T,
                   lwd = 0.3,
                   y_limits = c(0, 5.3),
                   y_lab = "",
                   y_breaks = seq(0, 5, 0.5),
                   x.axis = F,
                   display_gts = F,
                   main = "MBD",
                   main.size = 15,
                   axes.labelsize = 10,
                   ticks.labelsize = 6,
                   ticks.lwd = 0.25,
                   panel_border_lwd = 0.1)

ex_mbd <- rtt_plot(rtt_mbd, type = "ex",
                   restrict_y = F,
                   stage_x_breaks = F,
                   manual_x_breaks = seq(0, 30, 5),
                   display_OliNeo = T,
                   lwd = 0.3,
                   y_limits = c(0, 3.52),
                   y_breaks = seq(0, 3, 0.5),
                   several_gts = TRUE,
                   y_lab = "",
                   geoscale = gsc1,
                   geoscale2 = gsc4,
                   geoscale_height = unit(0.5, "line"),
                   abbr = list(TRUE, FALSE),
                   axes.labelsize = 10,
                   ticks.labelsize = 6,
                   ticks.lwd = 0.25,
                   geoscale_labelsize = list(1, 2),
                   geoscale_lwd = 0.1,
                   panel_border_lwd = 0.1) 

## Arrange ---------------------------------------------------------------------
full_plot <- ggarrange(plotlist = list(sp_rj, sp_bd, sp_mbd, ex_rj, ex_bd, ex_mbd),
                       ncol = 3, nrow = 2, labels = c("(A)", "(C)", "(E)", "(B)", "(D)", "(F)"),
                       hjust = -0.3)

ggsave("./Figures/Main/Diversification_rates.pdf", full_plot,
       height = 150, width = 200, units = "mm")
ggsave("./Figures/Main/Diversification_rates.png", full_plot,
       height = 150, width = 200, units = "mm", dpi = 600)
