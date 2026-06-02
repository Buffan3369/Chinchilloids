################################################################################
# Name: 1b-Prepare_PyRate_inputs.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Prepare PyRate inputs for genus-level occurrence data without 
#              'sp.' or indet
################################################################################

library(tidyverse)
library(readxl)
source("~/PyRate/pyrate_utilities.r")
source("./R/useful/helper_functions.R")

## Open databases --------------------------------------------------------------
# Fossil occurrences
chinchi <- read_xlsx("./Data/OccDB_cleaned/ChinchilloideaOccurrences_cleaned.xlsx")
chinchi$min_ma <- as.numeric(chinchi$min_ma)
chinchi$max_ma <- as.numeric(chinchi$max_ma)
# Extant species lacking fossil record
extant_chinchi <- read.table("./Data/OccDB_cleaned/extant_taxa_with_no_fossils.txt",
                             header = T)

## Genus-level database without indets -----------------------------------------
chinchi_gen <- chinchi %>%
  select(genus, gen_lvl_status, sp_lvl_status, min_ma, max_ma) %>%
  filter(!is.na(sp_lvl_status)) %>% 
  dplyr::select(!all_of("sp_lvl_status")) %>% 
  rename(Species = "genus", Status = "gen_lvl_status", min_age = "min_ma", max_age = "max_ma")
  

# Remove occurrences assigned to open nomenclature elements
true_gen <- sapply(X = chinchi_gen$Species,
                   FUN = open_checkR)
chinchi_gen <- chinchi_gen[true_gen, ]

# Add extant genera
extant_gen <- extant_chinchi %>% 
  mutate(Species = sapply(X = Species,
                          FUN = function(x){strsplit(x, "_")[[1]][1]}))
chinchi_gen <- rbind(chinchi_gen, extant_gen)

# -- 1- Full -- 
# Save occurrence dataframe
write.table.lucas(chinchi_gen, "./Data/PyRate_inputs/Genus/4-Chinchilloidea_Genus_NoIndet.txt")
# Extract ages
extract.ages("./Data/PyRate_inputs/Genus/4-Chinchilloidea_Genus_NoIndet.txt", replicates = 20)
