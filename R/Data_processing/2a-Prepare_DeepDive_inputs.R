################################################################################
# Name: 3a-Prepare_DeepDive_inputs.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Prepare DeepDive inputs for cleaned Chinchilloidea occurrence data
################################################################################

library(tidyverse)
library(readxl)
library(DeepDiveR)
source("./R/useful/helper_functions.R")

# Input Chinchilloidea occurrence database
chinchi <- read_xlsx("./Data/OccDB_cleaned/ChinchilloideaOccurrences_cleaned.xlsx")
chinchi$min_ma <- as.numeric(chinchi$min_ma)
chinchi$max_ma <- as.numeric(chinchi$max_ma)

# Add locality identifier
# Flag the 23 occurrences with undefined locality and assign them a placeholder
loc_na <- which(is.na(chinchi$locality))
chinchi$locality[loc_na] <- paste0("Placeholder_", 1:length(loc_na))
# Create the locality identifier column
chinchi$loc_id <- NA
UnLoc <- unique(chinchi$locality)
for(i in 1:length(UnLoc)){
  trgt <- which(chinchi$locality == UnLoc[i])
  chinchi$loc_id[trgt] <- i
}

##########################################
## -------- Species-level data -------- ##
##########################################

# Preprocess
chinchi_sp <- chinchi %>% 
  select(accepted_name, loc, min_ma, max_ma, loc_id) %>% 
  rename(Taxon = "accepted_name", Region = "loc", MinAge = "min_ma", MaxAge = "max_ma", Locality = "loc_id")

# Save
write.table.lucas(chinchi_sp, "./Results/DeepDive/species/data/Chinchilloidea_species_level.txt")

# Time bins considered
bins <- seq(39, 0, -1)

# Generate DeepDive input
prep_dd_input(
  dat = chinchi_sp,
  bins = bins,
  r = 100,
  output_file = "./Results/DeepDive/species/data/Chinchilloidea_species_level_DD_input.csv"
)


########################################
## -------- Genus-level data -------- ##
########################################

rm(chinchi_sp)

# Preprocess
chinchi_gen <- chinchi %>% 
  select(genus, loc, min_ma, max_ma, loc_id) %>% 
  rename(Taxon = "genus", Region = "loc", MinAge = "min_ma", MaxAge = "max_ma", Locality = "loc_id")

# Save
write.table.lucas(chinchi_gen, "./Results/DeepDive/genus/data/Chinchilloidea_genus_level.txt")

# Generate DeepDive input
prep_dd_input(
  dat = chinchi_gen,
  bins = bins,
  r = 100,
  output_file = "./Results/DeepDive/genus/data/Chinchilloidea_genus_level_DD_input.csv"
)

