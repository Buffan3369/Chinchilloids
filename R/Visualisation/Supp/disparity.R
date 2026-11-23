################################################################################
# Name: disparity.R
# Author: Lucas Buffan (Lucas.L.Buffan@gmail.com)
# Aim: Plot two body mass disparity metrics (Mean pairwise distance & maximal 
#      Euclidian distance)
################################################################################

library(tidyverse)
source("./R/useful/helper_functions.R")
source("./R/useful/load_GTS.R")

gsc1$max_age[which.max(gsc1$max_age)] <- 34.5
gsc1$abbr[which(gsc1$abbr == "Eo")] <- ""
gsc1$abbr[which(gsc1$abbr == "Ol")] <- "Oligocene"
gsc1$abbr[which(gsc1$abbr == "Mio")] <- "Miocene"

gsc4 <- gsc4[-nrow(gsc4),]
gsc4$max_age[which.max(gsc4$max_age)] <- 34.5


bins <- data.frame(bin = 1:35,
                   min_ma = seq(0, 34, 1),
                   max_ma = seq(1, 35, 1))
binned_rats <- readRDS("./Data/Traits/Binned_BM.RDS")

## Compute the two disparity metrics -------------------------------------------
PD <- c()
RANGE <- c()
for(bin in 1:nrow(bins)){
  tmp <- binned_rats |> filter(bin_assignment == bin)
  # Mean pairwise distance
  PD <- c(PD, mean(dist(tmp$BM_kg), na.rm = T))
  # Range (maximal Euclidian distance)
  RANGE <- c(RANGE, ifelse(max(dist(tmp$BM_kg), na.rm = T) == -Inf, NA, max(dist(tmp$BM_kg), na.rm = T)))
}

## Plot ------------------------------------------------------------------------
t <- sapply(X = 1:nrow(bins),
            FUN = function(x){(bins$max_ma[x] + bins$min_ma[x])/2})
PLOT_DF <- data.frame(time = rep(t, 2),
                      Metric = c(rep("Mean Pariwise Distance", 35),
                                 rep("Maximal Euclidian Distance", 35)),
                      Value = c(PD, RANGE))

disparity_plot <- PLOT_DF |> 
  ggplot(aes(x = time, y = Value)) +
  scale_x_reverse() +
  # Temporal bands
  annotate(geom = "rect", xmin = 0, xmax = 2.58, ymin = -Inf, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 5.33, xmax = 11.63, ymin = -Inf, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 15.97, xmax = 23.03, ymin = -Inf, ymax = Inf, fill = "grey", alpha = 0.2) +
  annotate(geom = "rect", xmin = 27.82, xmax = 33.9, ymin = -Inf, ymax = Inf, fill = "grey", alpha = 0.2) +
  # GTS
  coord_geo(pos = list("bottom", "bottom"),
            lwd = 0.1,
            dat = list(gsc4, gsc1),
            abbrv = TRUE,
            center_end_labels = TRUE,
            size = list(1.5, 2),
            height = unit(0.6, "line"),
            clip = "off") +
  # Data
  geom_line(linetype = "dashed") +
  geom_point() +
  facet_wrap(.~Metric, scales = "free_y") + 
  labs(x = "Time (Ma)") +
  theme(axis.line = element_line(colour = "black", linewidth = 0.35),
        axis.title = element_text(size = 8),
        axis.text = element_text(size = 6),
        plot.title = element_text(size = 11, hjust = 0.5),
        panel.background = element_blank(),
        strip.background = element_rect(fill = "bisque2"))

ggsave("./Figures/Supp/Disparity.pdf", plot = disparity_plot,
       height = 130, width = 200, units = "mm")
