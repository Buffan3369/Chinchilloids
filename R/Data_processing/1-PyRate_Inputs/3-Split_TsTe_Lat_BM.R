################################################################################
# Name: 1c-Split_TsTe_Lat_BM.R
# Author: Lucas Buffan
# Contact: lucas.l.buffan@gmail.com
# Aim: Split TsTe of species per lat (Trop vs. Etrop) and BM categories
################################################################################

library(tidyverse)
library(readxl)
library(hash)
source("./R/useful/helper_functions.R")

## Preprocessing ---------------------------------------------------------------
TsTe_tbl <- read.table("./Results/RJMCMC/species/1-Full/LTT/1-Chinchilloidea_species_lvl_occ_10_Grj_KEEP_se_est.txt",
                       header = T)
# Species names
TL <- read.table("./Data/PyRate_inputs/Species/1-Chinchilloidea_sp_lvl_occ_EXTENDED_TaxonList.txt", header = T)
TsTe_tbl$species_name <- TL$Species
# Tropicality
chinchi <- read_xlsx("./Data/OccDB_cleaned/ChinchilloideaOccurrences_cleaned.xlsx")
TsTe_tbl$loc <- sapply(X = TsTe_tbl$species_name,
                       FUN = function(x){
                         loc <- unique(chinchi$loc[which(chinchi$accepted_name == x)])
                         if(length(loc) == 1){
                           return(loc)
                         }
                         else{
                           return("ET")
                         }
                       })
# BM category
BM <- read_xlsx("./Data/Traits/Species_Lists/Chinchilloidea_BodyMass_SpeciesList.xlsx")
TsTe_tbl$BM_cat <- sapply(X = TsTe_tbl$species_name,
                          FUN = function(x){
                            idx <- which(BM$name == x)
                            bm <- BM$`BodyMass category`[idx]
                            rtn <- ifelse(bm == "?", NA, bm)
                            return(rtn)
                          })

## Split -----------------------------------------------------------------------
# Tropicality
TsTe_trop <- TsTe_tbl %>%
  filter(loc %in% c("ET", "T")) %>% 
  select(!c(species_name, loc, BM_cat))

TsTe_etrop <- TsTe_tbl %>%
  filter(loc %in% c("ET", "E")) %>% 
  select(!c(species_name, loc, BM_cat))

write.table.lucas(TsTe_etrop, "./Data/PyRate_inputs/Species/Lat_TsTe/Chinchilloid_extratropical_species_se_est.txt")
write.table.lucas(TsTe_trop, "./Data/PyRate_inputs/Species/Lat_TsTe/Chinchilloid_tropical_species_se_est.txt")

# BM cat
BM_cats <- hash("1" = "XS", "2" = "S", "3" = "M", "4" = "L", "5" = "XL", "6" = "XXL")
for(cat in keys(BM_cats)){
  tmp_tbl <- TsTe_tbl %>% 
    filter(BM_cat == cat) %>% 
    select(!c(species_name, loc, BM_cat))
  write.table.lucas(tmp_tbl,
                    paste0("./Data/PyRate_inputs/Species/BM_TsTe/Chinchilloid_", values(BM_cats[cat]), "_species_se_est.txt"))
}

