################################################################################
# Name: 1b-Prepare_PyRate_inputs.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Prepare PyRate inputs for cleaned Chinchilloidea occurrence data
################################################0################################

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
write.table.lucas(chinchi_gen, "./Data/PyRate_inputs/Genus/1-Chinchilloidea_genus_lvl_occ.txt")
# Extract ages
extract.ages("./Data/PyRate_inputs/Genus/1-Chinchilloidea_genus_lvl_occ.txt", replicates = 20)

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
write.table.lucas(chinchi_gen_spat_scld, "./Data/PyRate_inputs/Genus/3-Spatially_scaled_Chinchilloidea_gen.txt")

# Extract ages
extract.ages("./Data/PyRate_inputs/Genus/3-Spatially_scaled_Chinchilloidea_gen.txt", replicates = 20)


## Species-level database --------------------------------------------------------
chinchi_sp <- chinchi %>%
  select(accepted_name, sp_lvl_status, min_ma, max_ma) %>%
  filter(!is.na(sp_lvl_status)) %>% # filter out occurrences at the genus level
  rename(Species = "accepted_name", Status = "sp_lvl_status", min_age = "min_ma", max_age = "max_ma")

# Remove occurrences associated with open nomenclature
true_sp <- sapply(X = chinchi_sp$Species,
                  FUN = open_checkR)
chinchi_sp <- chinchi_sp[true_sp, ]

# Save data without extant lineages & extract ages
write.table.lucas(chinchi_sp %>% 
                    filter(!(Species %in% c("Chinchilla_chinchilla", "Lagidium_viscacia"))), 
                  "./Data/PyRate_inputs/Species/2-Chinchilloidea_sp_lvl_occ_FossilOnly.txt")
extract.ages("./Data/PyRate_inputs/Species/2-Chinchilloidea_sp_lvl_occ_FossilOnly.txt", replicates = 20)

# Add an occurrence of min_age = max_age = 0 for each extant species
chinchi_sp_extendedRaw <- chinchi_sp %>% 
  add_row(Species = c("Chinchilla_chinchilla", "Chincilla_lanigera", "Lagidium_viscacia", "Lagidium_ahuacaense",
                      "Lagidium_peruanum", "Lagidium_wolffsohni", "Lagostomus_maximus", "Dinomys_branickii"),
          Status = rep("extant", 8),
          min_age = rep(0, 8),
          max_age = rep(0, 8))

# Save raw combination & extract ages
write.table.lucas(chinchi_sp_extendedRaw, 
                  "./Data/PyRate_inputs/Species/4-Chinchilloidea_sp_lvl_occ_RawComb.txt")
extract.ages("./Data/PyRate_inputs/Species/4-Chinchilloidea_sp_lvl_occ_RawComb.txt", replicates = 20)


# Add simulated occurrences of extant taxa (see `1c-extant_Ts_sampling.R`)
chinchi_sp_comb <- rbind(chinchi_sp, extant_chinchi)

# Save occurrence dataframe & extract ages
write.table.lucas(chinchi_sp_comb, "./Data/PyRate_inputs/Species/1-Chinchilloidea_sp_lvl_occ.txt")
extract.ages("./Data/PyRate_inputs/Species/1-Chinchilloidea_sp_lvl_occ.txt", replicates = 20)


## Display descriptive stats on occ db -----------------------------------------
ct_sp <- chinchi_sp %>% count(Species)
ct_gen <- chinchi_gen %>% count(Species)
cat(paste0("The complete species-level database comprises ", nrow(chinchi_sp), " occurrences for ",
           nrow(ct_sp), " species, including ", length(which(ct_sp$n == 1)), " singletons.\n",
           "The complete genus-level database comprises ", nrow(chinchi_gen), " occurrences for ",
           nrow(ct_gen), " genera, including ", length(which(ct_gen$n == 1)), " singletons.\n"))


## Removing Caribbean taxa -----------------------------------------------------
chinchi_sp_NoCar <- chinchi_sp %>% 
  filter(Species %in% c("Amblyrhiza_inundata", "Elasmodontomys_obliquus",
                        "Quemisia_gravis", "Clidomys_osborni", "Borikenomys_praecursor") == F)
# Save occurrence dataframe
write.table.lucas(chinchi_sp_NoCar, "./Data/PyRate_inputs/Species/3-Chinchilloidea_sp_lvl_NoCar.txt")
# Extract ages
extract.ages("./Data/PyRate_inputs/Species/3-Chinchilloidea_sp_lvl_NoCar.txt", replicates = 20)
