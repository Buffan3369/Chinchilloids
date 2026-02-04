################################################################################
# Name: 1-Process_chinchi.R
# Author (e-mail): Lucas Buffan (lucas.l.buffan@gmail.com)
# Aim: Put together cleaned Chinchilloidea occurrences of Palaeogene and 
#      Neogene ages.
################################################################################

library(readxl)
library(tidyverse)

source("./R/useful/helper_functions.R")

# Palaeogene taxa

# spl_palaeogene <- readRDS("../Chapter_1/data_2023/SPECIES_LISTS/5-Fully_cleaned_EOT_SA_Mammals_SALMA_kept_Tropics_Diet.RDS")
# cavio_palaeogene <- spl_palaeogene %>% 
#   filter(order == "Rodentia") %>% 
#   # add_column(superfamily = NA, .after = "order") %>% 
#   add_column(museum_nb = NA, .after = "collection_no") %>% 
#   mutate(`Revised by` = "Laurent") %>% 
#   rename(sp_lvl_status = "status") %>% 
#   select(!c(p_lng, p_lat, age, lon, diet))
# write.table.lucas(cavio_palaeogene, "../Chapter_1/data_2023/SPECIES_LISTS/Chinchilloidea.txt")
# rm(spl_palaeogene, cavio_palaeogene)

cavio_palaeogene <- read_xlsx("../Chapter_1/data_2023/SPECIES_LISTS/Chinchilloidea_Palaeogene_improved.xlsx")

# Neogene taxa
cavio_neogene <- read_xlsx("./Data/OccDB_cleaned/Old/Neogene_Quaternary_Caviomorpha_CLEANED_MB_LB.xlsx")
cavio_neogene <- cavio_neogene %>% 
  # add_column(superfamily = NA, .after = "order") %>% 
  mutate(`epoch-stage` = sapply(1:nrow(cavio_neogene),
                                FUN = function(x){
                                  ifelse(is.na(cavio_neogene$SALMA[x]),
                                         cavio_neogene$`epoch-stage`[x],
                                         cavio_neogene$SALMA[x])})) %>% 
  select(!c(`taxon_name in original publication`, taxon_name, SALMA, FORMER_min_ma, FORMER_max_ma, `Type and Ref`, Rq, Comment, diet)) %>% 
  rename(stage = "epoch-stage", min_ma = "min_ma (BP)", max_ma = "max_ma (BP)") %>% 
  relocate(any_of(colnames(cavio_palaeogene)))

# Merge both
cavio_tot <- rbind.data.frame(cavio_neogene, cavio_palaeogene)
  
stem_chinchilloidea <- c("Borikenomys", "Cephalomys", "Chambiramys", "Eoincamys", "Loncolicu", 
                         "Microscleromys", "Garridomys", "Maquiamys")
chinchilloidea_fam <- c("Chinchillidae", "Cephalomyidae", "Dinomyidae", "Neoepiblemidae", "?Heptaxodontidae")

chinchi_occ <- cavio_tot %>% 
  filter(genus %in% stem_chinchilloidea | family %in% chinchilloidea_fam)

# Set species-level status of occurrences at the genus level as NA
na_sp <- sapply(chinchi_occ$accepted_name, 
                FUN = function(x){
                  spl <- strsplit(x, split = "_")[[1]]
                  ifelse(length(spl) == 1, T, F)
                })
chinchi_occ$sp_lvl_status[na_sp] <- NA
# Lagostomus (Lagostomopsis) issue (sub-genus invalidaetd by Rasia & Candela 2016)
chinchi_occ$sp_lvl_status[which(chinchi_occ$accepted_name == "Lagostomus_(Lagostomopsis)")] <- NA

# Save
write.table.lucas(chinchi_occ, "./Data/OccDB_cleaned/Old/Chinchilloidea_cleaned.txt")

## Taxonomic counter -----------------------------------------------------------
  # Number of recognised genera
cat(paste0("Total number of recognised genera in our dataset : ", length(unique(chinchi_occ$genus))))

  # Number of recognised species
a <- unique(chinchi_occ$accepted_name)
tf <- sapply(X = a, 
             FUN = function(x){
               b <- strsplit(x, split = "_")[[1]]
               rtn <- T
               if(length(b) > 1){
                 if("cf." %in% b | "aff." %in% b){ # Not recognised species
                   rtn <- F
                 }
                 if(length(b) == 2 & b[[2]] == "(Lagostomopsis)"){
                   rtn <- F
                 }
               }
               else{
                 rtn <- F
               }
               return(rtn)
             })
cat(paste0("Total number of recognised species in our dataset : ", length(which(tf == T))))
