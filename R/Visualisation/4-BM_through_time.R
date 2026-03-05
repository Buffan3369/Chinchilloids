################################################################################
# Name: 4-BM_through_time.R
# Author: Lucas Buffan (Lucas.L.Buffan@gmail.com)
# Aim: Plot body mass through time in the Chinchilloidea
################################################################################

library(tidyverse)
library(palaeoverse)
library(ggpubr)

source("./R/useful/load_GTS.R")

TsTe_BM <- readRDS("./Data/Traits/TsTe_tbl_with_BMs.RDS")
TsTe_BM <- TsTe_BM %>% rename(min_ma = "te", max_ma = "ts")

## Median ----------------------------------------------------------------------
bins <- data.frame(bin = 1:35,
                   min_ma = c(seq(0, 34, 1)),
                   max_ma = c(seq(1, 35, 1)))

binned_rats <- bin_time(occdf = TsTe_BM,
                        bins = bins,
                        method = "all")

unique_mid <- unique(binned_rats$bin_midpoint)
median_BM <- c()
for(t in unique_mid){
  median_BM_t <- median(binned_rats$BM_kg[which(binned_rats$bin_midpoint == t)], na.rm = T)
  median_BM <- c(median_BM, median_BM_t)
}

ds <- data.frame(time = unique_mid,
                 BM = median_BM)
ds <- ds[order(ds$time),]
row.names(ds) <- 1:nrow(ds)
ds$bin_length <- rep(1, 34)

# Assess mean body mass at present
TsTe_BM_extant <- TsTe_BM %>% filter(min_ma == 0)
med_BM_extant <- median(TsTe_BM_extant$BM_kg)

plot <- ds %>% 
  ggplot(aes(x = time, y = BM, width = bin_length)) +
  geom_bar(stat = "identity", fill = "white", colour = "black") +
  scale_x_reverse() +
  labs(x = "Time (Ma)", y = "Median body mass (kg)") +
  annotate(geom = "segment", x = 0, xend = 0, y = 0, yend = med_BM_extant, colour = "red", linewidth = 1) +
  annotate(geom = "point", x = 0, y = med_BM_extant, shape = 19, colour = "black", size = 2)

breaks <- sapply(X = c(0.1, 0.5, 1, 3, 5, 10, 20, 30, 35),
                 FUN = function(x){return(log10(x))})

logplot <- ds %>% 
  ggplot(aes(x = time, y = log(BM, base = 10), width = bin_length)) +
  geom_bar(stat = "identity", fill = "white", colour = "black") +
  scale_x_reverse() +
  scale_y_continuous(breaks = breaks,
                     labels = c(0.1, 0.5, 1, 3, 5, 10, 20, 30, 35)) +
  labs(x = "Time (Ma)", y = "Median body mass (kg)") +
  annotate(geom = "segment", x = 0, xend = 0, y = 0, yend = log(med_BM_extant, base = 10), colour = "red", linewidth = 1) +
  annotate(geom = "point", x = 0, y = log(med_BM_extant, base = 10), shape = 19, colour = "black", size = 2)


p <- ggarrange(plot, logplot, ncol = 2, labels = c("(A)", "(B)"), hjust = -0.1)
ggsave("./Figures/Supp/median_BM_through_time.pdf", plot=p, height = 100, width = 200, units = "mm")
