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
                  restrict_y = T,
                  restrict_thr = 1.2,
                  display_OliNeo = T,
                  lwd = 0.3,
                  y_limits = c(0, 1.2),
                  y_breaks = seq(0, 1, 0.2),
                  x.axis = F,
                  display_gts = F,
                  y_lab = "Speciation rate",
                  main = "rjMCMC",
                  main.size = 15,
                  axes.labelsize = 10,
                  ticks.labelsize = 6,
                  ticks.lwd = 0.25,
                  panel_border_lwd = 0.1)

ex_rj <- rtt_plot(rtt_rj, type = "ex",
                  restrict_y = F,
                  stage_x_breaks = F, 
                  manual_x_breaks = seq(0, 30, 5),
                  display_OliNeo = T,
                  lwd = 0.3,
                  y_limits = c(0, 1.2),
                  y_breaks = seq(0, 1, 0.2),
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
  annotate(geom = "text", label = "*", x = 6, y = 1.1, size = 8, colour = "#e34a33")

## BDCS RTT --------------------------------------------------------------------
bdcs_rtt_pth <- "./Results/BDCS/species/combined_logs/combined_19marginal_rates_RTT.r"
bdcs_rtt <- extract_rtt(bdcs_rtt_pth, ana = "BDS")
# Adjust timing of rate shift
rate_shift_idx <- c(28, 24, 16, 12, 7, 3)
true_time <- c(27.8, 23.03, 15.97, 11.8, 6, 2.58)
for(i in rate_shift_idx){
  a <- which(rate_shift_idx == i)
  # Row to insert
  target_row_sup <- bdcs_rtt[i,]
  mod_row_sup <- unlist(c(true_time[a],
                          target_row_sup[-1]))
  target_row_inf <- bdcs_rtt[i+1,]
  mod_row_inf <- unlist(c(true_time[a]+0.000001, 
                          target_row_inf[-1]))
  # Cut data frame
  ds_sup <- bdcs_rtt[1:(i-1),]
  ds_inf <- bdcs_rtt[(i+1):nrow(bdcs_rtt),]
  # Insert modified fow
  bdcs_rtt <- rbind(ds_sup, mod_row_sup, mod_row_inf, ds_inf)
  rownames(bdcs_rtt) <- 1:nrow(bdcs_rtt)
}

sp_bdcs <- rtt_plot(bdcs_rtt, type = "sp",
                    restrict_y = T,
                    restrict_thr = 1.2,
                    display_OliNeo = T,
                    lwd = 0.3,
                    y_limits = c(0, 1.2),
                    y_breaks = seq(0, 1, 0.2),
                    x.axis = F,
                    display_gts = F,
                    y_lab = "Speciation rate",
                    main = "BDCS",
                    main.size = 15,
                    axes.labelsize = 10,
                    ticks.labelsize = 6,
                    ticks.lwd = 0.25,
                    panel_border_lwd = 0.1)

ex_bdcs <- rtt_plot(bdcs_rtt, type = "ex",
                    restrict_y = T,
                    restrict_thr = 1.2,
                    stage_x_breaks = F, 
                    manual_x_breaks = seq(0, 30, 5),
                    display_OliNeo = T,
                    lwd = 0.3,
                    y_limits = c(0, 1.2),
                    y_breaks = seq(0, 1, 0.2),
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
  annotate(geom = "text", label = "*", x = 6, y = 1.1, size = 8, colour = "#e34a33") +
  annotate(geom = "text", label = "?", x = 15.98, y = 1.15, size = 4, colour = "#e34a33")

## BDNN RTT (one replicate randomly chosen) ------------------------------------
path_to_BDNN <- "./Results/BDNN/BDNN_imputation_NoCar/Replicate_8/combined_logs/combined_10KEEP_RTT.r"
rtt_bdnn <- extract_rtt(path_to_BDNN, ana = "BDNN")
rtt_bdnn$time[which(rtt_bdnn$time == 
                      max(rtt_bdnn$time))] <- max(rtt_rj$time) # harmonise x scale

sp_bd <- rtt_plot(rtt_bdnn, type = "sp",
                  restrict_y = T,
                  restrict_thr = 1.2,
                  plot_bdnn = T,
                  display_OliNeo = T,
                  lwd = 0.3,
                  y_limits = c(0, 1.2),
                  y_breaks = seq(0, 1, 0.2),
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
                  y_limits = c(0, 1.2),
                  y_breaks = seq(0, 1, 0.2),
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
                  panel_border_lwd = 0.1) +
  annotate(geom = "text", label = "*", x = 6, y = 1.1, size = 8, colour = "#e34a33") +
  annotate(geom = "text", label = "?", x = 15.98, y = 1.15, size = 4, colour = "#e34a33")

## MBD RTT ---------------------------------------------------------------------
path_to_mbd_RTT <- "./Results/MBD/species_hsp0/combined_18_KEEP_RTT.r"
rtt_mbd <- extract_rtt(path_to_mbd_RTT, ana = "MBD")
# harmonise timescale with the two others
rtt_mbd <- rtt_mbd %>% filter(time <= max(rtt_rj$time))

sp_mbd <- rtt_plot(rtt_mbd, type = "sp",
                   restrict_y = F,
                   display_OliNeo = T,
                   lwd = 0.3,
                   y_limits = c(0, 1.2),
                   y_lab = "",
                   y_breaks = seq(0, 1, 0.2),
                   x.axis = F,
                   display_gts = F,
                   main = "MBD",
                   main.size = 15,
                   axes.labelsize = 10,
                   ticks.labelsize = 6,
                   ticks.lwd = 0.25,
                   panel_border_lwd = 0.1)

ex_mbd <- rtt_plot(rtt_mbd, type = "ex",
                   restrict_y = T,
                   restrict_thr = 1.2,
                   stage_x_breaks = F,
                   manual_x_breaks = seq(0, 30, 5),
                   display_OliNeo = T,
                   lwd = 0.3,
                   y_limits = c(0, 1.2),
                   y_breaks = seq(0, 1, 0.2),
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
                   panel_border_lwd = 0.1) +
  annotate(geom = "text", label = "*", x = 6, y = 1.1, size = 8, colour = "#e34a33") +
  annotate(geom = "text", label = "?", x = 15.98, y = 1.15, size = 4, colour = "#e34a33")

## Arrange ---------------------------------------------------------------------
full_plot <- ggarrange(plotlist = list(sp_rj, sp_bdcs, sp_bd, sp_mbd,
                                       ex_rj, ex_bdcs, ex_bd, ex_mbd),
                       ncol = 4, nrow = 2, 
                       labels = c("(A)", "(C)", "(E)", "(G)",
                                  "(B)", "(D)", "(F)", "(H)"),
                       font.label = list(size = 10),
                       vjust = c(rep(2, 4), rep(1.5, 4)))

ggsave("./Figures/Main/Diversification_rates.pdf", full_plot,
       height = 120, width = 250, units = "mm")
ggsave("./Figures/Main/Diversification_rates.png", full_plot,
       height = 120, width = 250, units = "mm", dpi = 600)
