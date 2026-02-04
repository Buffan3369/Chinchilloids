################################################################################
# Name: 4-BM_through_time.R
# Author: Lucas Buffan (Lucas.L.Buffan@gmail.com)
# Aim: Plot body mass through time in the Chinchilloidea
################################################################################

library(tidyverse)
library(palaeoverse)

source("./R/useful/load_GTS.R")

TsTe_BM <- readRDS("./Data/Traits/TsTe_tbl_with_BMs.RDS")
TsTe_BM <- TsTe_BM %>% rename(min_ma = "te", max_ma = "ts")

bins <- data.frame(bin = 1:25,
                   min_ma = seq(0, 36.5, 1.5),
                   max_ma = seq(1.5, 38, 1.5))

binned_rats <- bin_time(occdf = TsTe_BM,
                        bins = bins,
                        method = "all")

unique_mid <- unique(binned_rats$bin_midpoint)
mean_BM <- c()
for(t in unique_mid){
  mean_BM_t <- mean(binned_rats$BM_kg[which(binned_rats$bin_midpoint == t)], na.rm = T)
  mean_BM <- c(mean_BM, mean_BM_t)
}
ds <- data.frame(time = unique_mid,
                 BM = mean_BM)
plot(x = ds$time, y = ds$BM)
