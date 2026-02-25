################################################################################
# Name: 1b-Diversity.R
# Author: Lucas Buffan (Lucas.L.Buffan@gmail.com)
# Aim: Plot diversity through time estimated by PyRate & DeepDive
#      + preservation rate
################################################################################

library(ggpubr)
library(tidyverse)
library(cowplot)

## Source accessory functions for plotting -------------------------------------
source("~/Documents/GitHub/CorsaiR/R/1-extract_param_from_PyRate_outputs.R")
source("~/Documents/GitHub/CorsaiR/R/2-plotting_facilities.R")
source("./R/useful/helper_functions.R")
source("./R/useful/load_GTS.R")

gsc1$name[2] <- "Ple"
gsc1$name[3] <- "Plio"
gsc1$name[nrow(gsc1)] <- "E"


## DeepDive empirical predictions ----------------------------------------------
empi_pred_path <- "./Results/DeepDive/species_extant_extended/species_extant_extended_models/simulation_species_extant_extended_ET_20260224_lstm64_32_d64_32_conditional/"
dd_pred_table <- extract_DD_pred(empi_pred_path)
dd_pred_table$time[nrow(dd_pred_table)] <- 38.2 # cut

dd_div <- dd_pred_plot(dd_pred_tbl = dd_pred_table,
                       x_breaks = seq(0, 35, 5),
                       axes.labelsize = 10,
                       ticks.labelsize = 6,
                       x_lab = "Time (Ma)",
                       y_lab = "'Corrected' diversity",
                       main = "DeepDive",
                       main.size = 15,
                       y_limits = c(0, max(dd_pred_table$maj_M)+5),
                       y_breaks = seq(0, max(dd_pred_table$maj_M), 10),
                       lwd = 0.5,
                       display_gts = TRUE,
                       plot.border = FALSE,
                       several_gts = TRUE,
                       geoscale = gsc1,
                       geoscale2 = gsc4,
                       geoscale_height = unit(0.6, "line"),
                       geoscale_labelsize = list(1.5, 2),
                       geoscale_lwd = 0.15,
                       abbr = list(TRUE, FALSE)) +
  theme(axis.line.y = element_line(colour = "black", linewidth = 0.35)) +
  # Temporal bands
  annotate(geom = "rect", xmin = 0, xmax = 2.58, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 5.33, xmax = 11.63, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 15.97, xmax = 23.03, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 27.82, xmax = 33.9, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2)

## Load LTT table & plot -------------------------------------------------------
ltt_path <- "./Results/RJMCMC/species_extant_extended/1-Full/LTT/1-Chinchilloidea_sp_lvl_occ_EXTENDED_10_Grj_KEEP_se_est_ltt.txt"
ltt_tbl <- read.table(ltt_path, header = TRUE)
ltt_tbl <- ltt_tbl %>%
  rename("Age" = time, "Diversity" = diversity, "min_Diversity" = m_div, "max_Diversity" = M_div)

gsc1$max_age[nrow(gsc1)] <- max(ltt_tbl$Age)
gsc4$max_age[nrow(gsc4)] <- max(ltt_tbl$Age)
gsc4$abbr[nrow(gsc4)] <- NA

ltt.plot <- ltt_plot(ltt_tbl,
                     stage_x_breaks = FALSE,
                     manual_x_breaks = seq(0, 35, 5),
                     axes.labelsize = 10,
                     ticks.labelsize = 6,
                     x_lab = "Time (Ma)",
                     y_lab = "Diversity",
                     main = "PyRate",
                     main.size = 15,
                     y_limits = c(0, max(ltt_tbl$max_Diversity)+5),
                     y_breaks = seq(0, 30, 5),
                     lwd = 0.5,
                     display_gts = TRUE,
                     xlim = c(36, 0),
                     avg_col = "#006d2c",
                     ribbon_col = "#74c476",
                     plot.border = FALSE,
                     x.axis = TRUE,
                     several_gts = TRUE,
                     geoscale = gsc1,
                     geoscale2 = gsc4,
                     geoscale_height = unit(0.6, "line"),
                     geoscale_labelsize = list(1.5, 2),
                     geoscale_lwd = 0.15,
                     abbr = list(TRUE, FALSE)) +
  theme(axis.line.y = element_line(colour = "black", linewidth = 0.35)) +
  # Temporal bands
  annotate(geom = "rect", xmin = 0, xmax = 2.58, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 5.33, xmax = 11.63, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 15.97, xmax = 23.03, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 27.82, xmax = 33.9, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2)

## Combine ---------------------------------------------------------------------
div_plots <- ggarrange(plotlist = list(ltt.plot, dd_div),
                       ncol = 2, labels = list("(A)", "(B)"))

ggsave("./Figures/Main/Diversity_through_time.pdf", div_plots,
       height = 100, width = 200, units = "mm")
ggsave("./Figures/Main/Diversity_through_time.png", div_plots,
       height = 100, width = 200, units = "mm", dpi = 600)

## Preservation rate -----------------------------------------------------------
path_to_q <- "./Results/RJMCMC/species_extant_extended/1-Full/Q_SHIFTS/Parsed_Q_rates.txt"
q.table <- read.table(path_to_q, header = TRUE)
q.table <- q.table[-c(nrow(q.table)),] # remove Holocene preservation rates

# q-rates plot
Q_plot <- q_plot(q.table,
                 ltt_tbl,
                 stage_x_breaks = FALSE,
                 manual_x_breaks = seq(0, 35, 5),
                 y_breaks = seq(from = 0, 
                                to = round(max(q.table$max_HPD)), round(max(q.table$max_HPD))/4),
                 axes.labelsize = 15,
                 ticks.labelsize = 12,
                 several_gts = TRUE,
                 geoscale = gsc1,
                 geoscale2 = gsc4,
                 abbr = list(TRUE, FALSE),
                 geoscale_height = unit(1, "line"),
                 geoscale_labelsize = list(2.5, 3.5)) +
  annotate(geom = "rect", xmin = 27.82, xmax = 33.9, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
  annotate(geom = "rect", xmin = 15.97, xmax = 23.03, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
  annotate(geom = "rect", xmin = 11.63, xmax = 5.33, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
  annotate(geom = "rect", xmin = 0, xmax = 2.58, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0)

ggsave("./Figures/Supp/Preservation_through_time.pdf",
       plot = Q_plot, height = 150, width = 150, units = "mm")
ggsave("./Figures/Supp/Preservation_through_time.png",
       dpi = 600, plot = Q_plot, height = 150, width = 150, units = "mm")
