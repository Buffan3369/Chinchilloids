################################################################################
# Name: 4-BM_through_time.R
# Author: Lucas Buffan (Lucas.L.Buffan@gmail.com)
# Aim: Plot body mass through time in the Chinchilloidea
################################################################################

library(tidyverse)
library(palaeoverse)
library(pammtools)
library(ggpubr)

source("./R/useful/helper_functions.R")
source("./R/useful/load_GTS.R")


gsc1$max_age[which.max(gsc1$max_age)] <- 34.5
gsc1$abbr[which(gsc1$abbr == "Eo")] <- ""
gsc1$abbr[which(gsc1$abbr == "Ol")] <- "Oligocene"
gsc1$abbr[which(gsc1$abbr == "Mio")] <- "Miocene"

gsc4 <- gsc4[-nrow(gsc4),]
gsc4$max_age[which.max(gsc4$max_age)] <- 34.5

TsTe_BM <- readRDS("./Data/Traits/TsTe_tbl_with_BMs.RDS")
TsTe_BM <- TsTe_BM %>% rename(min_ma = "te", max_ma = "ts")

## Data processing -------------------------------------------------------------
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

# Smooth version
ds$time[1] <- 0.25 # for plotting
smooth_plot <- ds %>% 
  ggplot(aes(x = time, y = log10(BM*1000))) +
  geom_ribbon(aes(ymin = log10(minBM*1000), ymax = log10(maxBM*1000)), fill="purple", alpha = 0.2) +
  geom_line() +
  annotate(geom = "segment", x = 0, y = log10(min_BM_extant*1000), yend = log10(max_BM_extant*1000), colour = "red") +
  annotate(geom = "point", x = 0, y = log10(med_BM_extant*1000), shape = 19, colour = "black", size = 2) +
  scale_x_reverse() +
  scale_y_continuous(breaks = breaks,
                     labels = c(0.1, 0.5, 1, 2, 3, 5, 10, 20, 30, 50, 100, 200, 300),
                     limits = c(NA, log10(6e5))) +
  labs(x = "Time (Ma)", y = "Body Mass (kg)") +
  # Theme
  theme(axis.line = element_line(colour = "black", linewidth = 0.35),
        axis.text = element_text(size = 8),
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
            size = list(1.4, 2),
            height = unit(0.75, "line"),
            clip = "off")

# Step version
step_plot <- ds %>% 
  ggplot(aes(x = time, y = log10(BM*1000))) +
  geom_stepribbon(aes(ymin = log10(minBM*1000), ymax = log10(maxBM*1000)), fill="purple", alpha = 0.2) +
  geom_step() +
  annotate(geom = "segment", x = 0, y = log10(min_BM_extant*1000), yend = log10(max_BM_extant*1000), colour = "red") +
  annotate(geom = "point", x = 0, y = log10(med_BM_extant*1000), shape = 19, colour = "black", size = 2) +
  scale_x_reverse() +
  scale_y_continuous(breaks = breaks,
                     labels = c(0.1, 0.5, 1, 2, 3, 5, 10, 20, 30, 50, 100, 200, 300),
                     limits = c(NA, log10(6e5))) +
  labs(x = "Time (Ma)", y = NULL) +
  # Theme
  theme(axis.line = element_line(colour = "black", linewidth = 0.35),
        axis.text = element_text(size = 8),
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
            size = list(1.4, 2),
            height = unit(0.75, "line"),
            clip = "off")
  
p <- ggarrange(smooth_plot, step_plot, ncol = 2, labels = c("(A)", "(B)"), hjust = 0)
ggsave("./Figures/Supp/BM_through_time.pdf", plot=p, height = 90, width = 200, units = "mm")
