################################################################################
# Name: 1b-Diversity.R
# Author: Lucas Buffan (Lucas.L.Buffan@gmail.com)
# Aim: Plot diversity through time estimated by PyRate & DeepDive
#      + BM through time + preservation rate
################################################################################

library(ggpubr)
library(tidyverse)
library(palaeoverse)
library(cowplot)
library(rphylopic)

## Source accessory functions for plotting -------------------------------------
source("~/Documents/GitHub/CorsaiR/R/1-extract_param_from_PyRate_outputs.R")
source("~/Documents/GitHub/CorsaiR/R/2-plotting_facilities.R")
source("./R/useful/helper_functions.R")
source("./R/useful/load_GTS.R")

gsc1$max_age[which.max(gsc1$max_age)] <- 34.5
gsc1$abbr[which(gsc1$abbr == "Eo")] <- ""
gsc1$abbr[which(gsc1$abbr == "Ol")] <- "Oligocene"
gsc1$abbr[which(gsc1$abbr == "Mio")] <- "Miocene"

gsc4 <- gsc4[-nrow(gsc4),]
gsc4$max_age[which.max(gsc4$max_age)] <- 34.5




## Load LTT table & plot -------------------------------------------------------
ltt_path <- "./Results/RJMCMC/species/1-Full/LTT/1-Chinchilloidea_sp_lvl_occ_10_Grj_KEEP_se_est_ltt.txt"
ltt_tbl <- read.table(ltt_path, header = TRUE)
ltt_tbl <- ltt_tbl %>%
  rename("Age" = time, "Diversity" = diversity, "min_Diversity" = m_div, "max_Diversity" = M_div) %>% 
  filter(Age <= 34.5)
ltt_tbl$Age[which.max(ltt_tbl$Age)] <- 34.5

ltt.plot <- ltt_plot(ltt_tbl,
                     stage_x_breaks = FALSE,
                     manual_x_breaks = seq(0, 35, 5),
                     axes.labelsize = 8,
                     ticks.labelsize = 6,
                     x_lab = NULL,
                     y_lab = "# species",
                     main = "Sampled Diversity (PyRate)",
                     main.size = 11,
                     y_limits = c(0, 27),
                     y_breaks = seq(0, 25, 5),
                     show_culotte = TRUE,
                     lwd = 0.5,
                     display_gts = FALSE,
                     xlim = c(34.5, 0),
                     avg_col = "#006d2c",
                     ribbon_col = "#74c476",
                     plot.border = FALSE,
                     x.axis = FALSE) +
  theme(axis.line.y = element_line(colour = "black", linewidth = 0.35)) +
  # Temporal bands
  annotate(geom = "rect", xmin = 0, xmax = 2.58, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 5.33, xmax = 11.63, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 15.97, xmax = 23.03, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 27.82, xmax = 33.9, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2)

## DeepDive empirical predictions ----------------------------------------------
empi_pred_path <- "./Results/DeepDive/species_extant_extended/species_extant_extended_models/simulation_species_extant_extended_ET_20260224_lstm64_32_d64_32_conditional/"
dd_pred_table <- extract_DD_pred(empi_pred_path)
dd_pred_table <- dd_pred_table %>% filter(time <= 35)
dd_pred_table$time[nrow(dd_pred_table)] <- 34.5 # cut

dd_div <- dd_pred_plot(dd_pred_tbl = dd_pred_table,
                       x_breaks = seq(0, 30, 5),
                       axes.labelsize = 8,
                       ticks.labelsize = 6,
                       x.axis = FALSE,
                       x_lab = NULL,
                       y_lab = "# species",
                       main = "Corrected Diversity (DeepDive)",
                       show_culotte = TRUE,
                       main.size = 11,
                       y_limits = c(0, max(dd_pred_table$maj_M)+5),
                       y_breaks = seq(0, max(dd_pred_table$maj_M), 10),
                       lwd = 0.5,
                       display_gts = FALSE) +
  theme(axis.line.y = element_line(colour = "black", linewidth = 0.35),
        panel.border = element_blank()) +
  # Temporal bands
  annotate(geom = "rect", xmin = 0, xmax = 2.58, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 5.33, xmax = 11.63, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 15.97, xmax = 23.03, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 27.82, xmax = 33.9, ymin = 0, ymax = Inf, fill = "grey", alpha = 0.2)


## Body Mass through time plot -------------------------------------------------
TsTe_BM <- readRDS("./Data/Traits/TsTe_tbl_with_BMs.RDS")
TsTe_BM <- TsTe_BM %>% rename(min_ma = "te", max_ma = "ts")

bins <- data.frame(bin = 1:35,
                   min_ma = seq(0, 34, 1),
                   max_ma = seq(1, 35, 1))

binned_rats <- bin_time(occdf = TsTe_BM,
                        bins = bins,
                        method = "all")

unique_mid <- unique(binned_rats$bin_midpoint)
median_BM <- c()
min_BM <- c()
max_BM <- c()
for(t in unique_mid){
  median_BM_t <- median(binned_rats$BM_kg[which(binned_rats$bin_midpoint == t)], na.rm = T)
  min_BM_t <- min(binned_rats$BM_kg[which(binned_rats$bin_midpoint == t)], na.rm = T)
  max_BM_t <- max(binned_rats$BM_kg[which(binned_rats$bin_midpoint == t)], na.rm = T)
  
  median_BM <- c(median_BM, median_BM_t)
  min_BM <- c(min_BM, min_BM_t)
  max_BM <- c(max_BM, max_BM_t)
}

ds <- data.frame(time = unique_mid,
                 BM = median_BM,
                 minBM = min_BM,
                 maxBM = max_BM)
ds <- ds[order(ds$time),]
row.names(ds) <- 1:nrow(ds)

# Assess mean body mass at present
TsTe_BM_extant <- TsTe_BM %>% filter(min_ma == 0)
med_BM_extant <- median(TsTe_BM_extant$BM_kg)
min_BM_extant <- min(TsTe_BM_extant$BM_kg)
max_BM_extant <- max(TsTe_BM_extant$BM_kg)

breaks <- sapply(X = c(0.1, 0.5, 1, 2, 3, 5, 10, 20, 30, 50, 100, 200, 300),
                 FUN = function(x){return(log10(1000*x))})
ds$time[1] <- 0.25 # for plotting

step_plot <- ds %>% 
  ggplot(aes(x = time, y = log10(BM*1000))) +
  # Lolo's segments
  annotate(geom = "segment", x = 27.82, xend = 27.82, y = 1.99, yend = Inf, linetype = "dashed", linewidth = 0.2, colour = "grey80") +
  annotate(geom = "segment", x = 23.04, xend = 23.04, y = 1.99, yend = Inf, linetype = "dashed", linewidth = 0.2, colour = "grey80") +
  annotate(geom = "segment", x = 15.97, xend = 15.97, y = 1.99, yend = Inf, linetype = "dashed", linewidth = 0.2, colour = "grey80") +
  annotate(geom = "segment", x = 11.63, xend = 11.63, y = 1.99, yend = Inf, linetype = "dashed", linewidth = 0.2, colour = "grey80") +
  annotate(geom = "segment", x = 5.33, xend = 5.33, y = 1.99, yend = Inf, linetype = "dashed", linewidth = 0.2, colour = "grey80") +
  annotate(geom = "segment", x = 2.58, xend = 2.58, y = 1.99, yend = Inf, linetype = "dashed", linewidth = 0.2, colour = "grey80") +
  # Actual plot
  geom_stepribbon(aes(ymin = log10(minBM*1000), ymax = log10(maxBM*1000)), fill="purple", alpha = 0.2) +
  geom_step(colour = "#980043") +
  annotate(geom = "segment", x = 0, y = log10(min_BM_extant*1000), yend = log10(max_BM_extant*1000), colour = "red") +
  annotate(geom = "point", x = 0, y = log10(med_BM_extant*1000), shape = 19, colour = "black", size = 2) +
  scale_x_reverse(breaks = seq(0, 30, 5), expand = c(0, 0)) +
  scale_y_continuous(breaks = breaks,
                     labels = c(0.1, 0.5, 1, 2, 3, 5, 10, 20, 30, 50, 100, 200, 300),
                     limits = c(NA, log10(5e5))) +
  labs(x = "Time (Ma)", y = "Body Mass (kg)") +
  ggtitle(label = "Body Mass through time") +
  # Theme
  theme(axis.line = element_line(colour = "black", linewidth = 0.35),
        axis.title = element_text(size = 8),
        axis.text = element_text(size = 6),
        plot.title = element_text(size = 11, hjust = 0.5),
        panel.background = element_blank()) +
  # Temporal bands
  annotate(geom = "rect", xmin = 0, xmax = 2.58, ymin = 1.9, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 5.33, xmax = 11.63, ymin = 1.9, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 15.97, xmax = 23.03, ymin = 1.9, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 27.82, xmax = 33.9, ymin = 1.9, ymax = Inf, fill = "grey", alpha = 0.2) +
  # GTS
  coord_geo(pos = list("bottom", "bottom"),
            lwd = 0.1,
            dat = list(gsc4, gsc1),
            abbrv = TRUE,
            center_end_labels = TRUE,
            size = list(1.5, 2),
            height = unit(0.6, "line"),
            clip = "off")


## Combine ---------------------------------------------------------------------
div_BM_plots <- ggarrange(plotlist = list(ltt.plot, dd_div, step_plot),
                          nrow = 3,
                          labels = list("(A)", "(B)", "(C)"), 
                          font.label = list(size = 10), vjust = 3)

ggsave("./Figures/Main/Diversity_and_BM_through_time.pdf", div_BM_plots,
       height = 200, width = 70, units = "mm")

ggsave("./Figures/Main/Diversity_and_BM_through_time.png", div_BM_plots,
       height = 200, width = 70, units = "mm", dpi = 600)

## Preservation rate -----------------------------------------------------------
path_to_q <- "./Results/RJMCMC/species/1-Full/Q_SHIFTS/Parsed_Q_rates.txt"
q.table <- read.table(path_to_q, header = TRUE)
q.table <- q.table[-c(nrow(q.table)),] # remove Holocene preservation rates

# q-rates plot
Q_plot <- q_plot(q.table,
                 ltt_tbl,
                 stage_x_breaks = FALSE,
                 manual_x_breaks = seq(0, 35, 5),
                 y_breaks = seq(from = 0, 
                                to = round(max(q.table$max_HPD)), 
                                as.integer(round(max(q.table$max_HPD))/4)),
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
