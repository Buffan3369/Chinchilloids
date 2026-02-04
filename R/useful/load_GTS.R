################################################################################
# Name: load_gts.R
# Author: Lucas Buffan
# Contact: lucas.l.buffan@gmail.com
# Aim: Load geological timescales.
################################################################################

library(tidyverse)
library(readxl)
library(deeptime)

# GEOSCALES
# First geoscale (epochs)
gsc1 <- deeptime::epochs
gsc1 <- gsc1 %>% filter(max_age <= 56)
gsc1$max_age[nrow(gsc1)] <- 38.2 # for plotting issues

# Second geoscale (stages)
gsc2 <- deeptime::stages
gsc2 <- gsc2 %>% filter(max_age <= 41.2)

# Set third geoscale (SALMAs)
gsc3 <- read_xlsx("./Data/time_bins/SALMAs.xlsx")

# Set fourth geoscale (SALMAs more abbreviated)
gsc4 <- read_xlsx("./Data/time_bins/SALMAs_abbr.xlsx")
