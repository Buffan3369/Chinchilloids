################################################################################
# Name: 1b-Prepare_PyRate_inputs.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Prepare PyRate inputs for cleaned Chinchilloidea occurrence data
################################################################################

library(tidyverse)
library(readxl)
source("~/PyRate/pyrate_utilities.r")
source("./R/useful/helper_functions.R")

## Open databases --------------------------------------------------------------
  # Fossil occurrences
#chinchi <- read_xlsx("./Data/OccDB_cleaned/ChinchilloideaOccurrences_cleaned.xlsx")
chinchi <- read_xlsx("./Data/OccDB_cleaned/ChinchilloideaOccurrences_cleaned-AMD45.xlsx") # With new taxa from Arnal et al. (2026)
chinchi$min_ma <- as.numeric(chinchi$min_ma)
chinchi$max_ma <- as.numeric(chinchi$max_ma)
  # Extant species lacking fossil record
extant_chinchi <- read.table("./Data/OccDB_cleaned/extant_taxa_with_no_fossils.txt",
                             header = T)

## Genus-level database --------------------------------------------------------
chinchi_gen <- chinchi %>%
  select(genus, gen_lvl_status, min_ma, max_ma) %>%
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
#write.table.lucas(chinchi_gen, "./Data/PyRate_inputs/Genus/1-Chinchilloidea_genus_lvl_occ.txt")
write.table.lucas(chinchi_gen, "./Data/PyRate_inputs/Genus/1-Chinchilloidea_genus_lvl_occ-AMD45.txt")
# Extract ages
#extract.ages("./Data/PyRate_inputs/Genus/1-Chinchilloidea_genus_lvl_occ.txt", replicates = 20)
extract.ages("./Data/PyRate_inputs/Genus/1-Chinchilloidea_genus_lvl_occ-AMD45.txt", replicates = 20)

  # -- 2. Spatially scaled -- 
loc_na <- which(is.na(chinchi$locality))
chinchi$locality[loc_na] <- paste0("Placeholder_", 1:length(loc_na))

chinchi_gen_spat_scld <- chinchi %>% 
  group_by(genus, gen_lvl_status, locality, min_ma, max_ma) %>%
  distinct(genus) %>%
  ungroup() %>%
  select(genus, gen_lvl_status, min_ma, max_ma) %>%
  rename(Species = "genus", Status = "gen_lvl_status", min_age = "min_ma", max_age = "max_ma")
# Save occurrence dataframe
#write.table.lucas(chinchi_gen_spat_scld, "./Data/PyRate_inputs/Genus/3-Spatially_scaled_Chinchilloidea_gen.txt")
write.table.lucas(chinchi_gen_spat_scld, "./Data/PyRate_inputs/Genus/3-Spatially_scaled_Chinchilloidea_gen-AMD45.txt")
# Extract ages
#extract.ages("./Data/PyRate_inputs/Genus/3-Spatially_scaled_Chinchilloidea_gen.txt", replicates = 20)
extract.ages("./Data/PyRate_inputs/Genus/3-Spatially_scaled_Chinchilloidea_gen-AMD45.txt", replicates = 20)


## Species-level database --------------------------------------------------------
chinchi_sp <- chinchi %>%
  select(accepted_name, sp_lvl_status, min_ma, max_ma) %>%
  filter(!is.na(sp_lvl_status)) %>% # filter out occurrences at the genus level
  rename(Species = "accepted_name", Status = "sp_lvl_status", min_age = "min_ma", max_age = "max_ma")

# Remove occurrences associated with open nomenclature
true_sp <- sapply(X = chinchi_sp$Species,
                  FUN = open_checkR)
chinchi_sp <- chinchi_sp[true_sp, ]

# Add simulated occurrences of extant taxa (see `1c-extant_Ts_sampling.R`)
chinchi_sp <- rbind(chinchi_sp, extant_chinchi)

# Save occurrence dataframe
#write.table.lucas(chinchi_sp, "./Data/PyRate_inputs/Species/1-Chinchilloidea_sp_lvl_occ.txt")
#write.table.lucas(chinchi_sp, "./Data/PyRate_inputs/Species/1-Chinchilloidea_sp_lvl_occ_EXTENDED.txt")
write.table.lucas(chinchi_sp, "./Data/PyRate_inputs/Species/1-Chinchilloidea_sp_lvl_occ_EXTENDED-AMD45.txt")
# Extract ages
#extract.ages("./Data/PyRate_inputs/Species/1-Chinchilloidea_sp_lvl_occ_EXTENDED.txt", replicates = 20)
extract.ages("./Data/PyRate_inputs/Species/1-Chinchilloidea_sp_lvl_occ_EXTENDED-AMD45.txt", replicates = 20)

## Removing Caribbean taxa -----------------------------------------------------
chinchi_sp_NoCar <- chinchi_sp %>% 
  filter(Species %in% c("Amblyrhiza_inundata", "Elasmodontomys_obliquus",
                        "Quemisia_gravis", "Clidomys_osborni", "Borikenomys_praecursor") == F)
# Save occurrence dataframe
#write.table.lucas(chinchi_sp_NoCar, "./Data/PyRate_inputs/Species/3-Chinchilloidea_sp_lvl_NoCar.txt")
write.table.lucas(chinchi_sp_NoCar, "./Data/PyRate_inputs/Species/3-Chinchilloidea_sp_lvl_NoCar-AMD45.txt")
# Extract ages
#extract.ages("./Data/PyRate_inputs/Species/3-Chinchilloidea_sp_lvl_NoCar.txt", replicates = 20)
extract.ages("./Data/PyRate_inputs/Species/3-Chinchilloidea_sp_lvl_NoCar-AMD45.txt", replicates = 20)

## No need for species-level spatial scaling as occurrences were compiled accordingly

## Northern immigrants ----------------------------------------------------------
  # Carnivorans
# Carni <- read_xlsx("./Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/Carnivora-Tarquini_etal_2022.xlsx")
# Carni <- Carni %>% 
#   select(Taxon_name, Status, MinAge, MaxAge) %>% 
#   rename(Species = "Taxon_name", min_age = "MinAge", max_age = "MaxAge")
# write.table.lucas(Carni, "./Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/Carnivora_species_occ_Tarquini.txt")
# extract.ages("./Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/Carnivora_species_occ_Tarquini.txt", replicates = 10)
#   # Northern Herbivores
# NorthHerb <- read_xlsx("./Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/Northern_Herbivores-Tarquini_etal_2022.xlsx")
# NorthHerb <- NorthHerb %>% 
#   select(Taxon_name, Status, MinAge, MaxAge) %>% 
#   filter(Taxon_name != "Bos_taurus") %>% 
#   rename(Species = "Taxon_name", min_age = "MinAge", max_age = "MaxAge")
# write.table.lucas(NorthHerb, "./Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/Northern_herbivores_sp_occ_Tarquini.txt")
# extract.ages("./Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/Northern_herbivores_sp_occ_Tarquini.txt", replicates = 10)
