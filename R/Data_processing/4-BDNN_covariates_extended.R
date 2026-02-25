################################################################################
# Title: 6-BDNN_covariates.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Preprocess covariates that will be fed into BDNN.
################################################################################

library(tidyverse)
library(readxl)
source("./R/useful/helper_functions.R")

transf_features_tbl <- data.frame(Temperature = c(NA, NA),
                                  Andean_uplift = c(NA, NA),
                                  Sea_level = c(NA, NA),
                                  Self_diversity = c(NA, NA),
                                  Body_mass = c(NA, NA),
                                  Hypsodonty = c(NA, NA))

## Continuous correlates -------------------------------------------------------
### Regional South American temperature (Tardif et al. 2025) ###
temp <- read.table("./Data/MBD_predictors/SA_regional_temperatures_Tardif_2025.txt", header = T)
# Downscale to a 0.5My time step
selected_indices <- sapply(X = seq(0, 38, 0.5), FUN = select_closer, age_vect = temp$Time)
temp500k <- temp[selected_indices, c(1, 2)] # only retain MAT
temp500k$Time <- seq(0, 38, 0.5) # Harmonise time vector
colnames(temp500k) <- c("Time", "Temperature")
  # Save mean and sd in tf table
mean_Temp <- mean(temp500k$Temperature, na.rm = T)
sd_Temp <- sd(temp500k$Temperature, na.rm = T)
transf_features_tbl$Temperature <- c(mean_Temp, sd_Temp)
  # Scale
covar_scaled <- temp500k %>% mutate(Temperature = (Temperature - mean_Temp)/sd_Temp)

### Andean Uplift ###
upl <- read.table("./Data/MBD_predictors/2-Average_Andean_uplift_500ky_step.txt", header = T)
  # Save moments
mean_upl <- mean(upl$elev, na.rm = T)
sd_upl <- sd(upl$elev, na.rm = T)
transf_features_tbl$Andean_uplift <- c(mean_upl, sd_upl)
  # Scale
covar_scaled <- covar_scaled %>% mutate(Andean_uplift = (upl$elev - mean_upl)/sd_upl)

### Sea level ###
slv <- read.table("./Data/MBD_predictors/3-Sea_level_500ky_step.txt", header = T)
  # Save moments
mean_slv <- mean(slv$Sea_level, na.rm = T)
sd_slv <- sd(slv$Sea_level, na.rm = T)
transf_features_tbl$Sea_level <- c(mean_slv, sd_slv)
  # Scale
covar_scaled <- covar_scaled %>% mutate(Sea_level = (slv$Sea_level - mean_slv)/sd_slv)

### Self-diversity (specific) ###
SelfDiv <- read.table("./Results/RJMCMC/species_extant_extended/1-Full/LTT/1-Chinchilloidea_sp_lvl_occ_EXTENDED_10_Grj_KEEP_se_est_ltt.txt",
                      header = T)
  # Downscale so it matches the timescale (last 38 Myrs with a 0.5Myr step)
selected_div <- sapply(X = seq(0, 38, 0.5), FUN = select_closer, age_vect = SelfDiv$time)
SelfDiv_down <- SelfDiv[selected_div, ] %>% 
  select(time, diversity) %>% 
  mutate(time = sapply(time, FUN = round, digits = 1)) # the last time is 37.9, we'll approximate to 38
  # Save the moments
mean_div <- mean(SelfDiv_down$diversity, na.rm = T)
sd_div <- sd(SelfDiv_down$diversity, na.rm = T)
transf_features_tbl$Self_diversity <- c(mean_div, sd_div)  
  # Scale
covar_scaled <- covar_scaled %>% mutate(Self_diversity = (SelfDiv_down$diversity - mean_div)/sd_div)

### Save time-continuous correlate table ###
write.table.lucas(covar_scaled, "./Data/BDNN_features_extended/Continuous_correlates.txt")



## Species-specific traits -----------------------------------------------------

### Body Mass
BM <- read_xlsx("./Data/Traits/Species_Lists/Chinchilloidea_BodyMass_SpeciesList.xlsx")
BM$`BodyMass category` <- as.numeric(BM$`BodyMass category`)
  # Save the median
median_bm_class <- median(BM$`BodyMass category`, na.rm = T)
transf_features_tbl$Body_mass <- c(median_bm_class, 1) # sd = 1 as discrete categories
  #Scale
BM <- BM %>% mutate(BM_class_scld = (`BodyMass category` - median_bm_class))
  # Store BM cat
categorical_traits <- data.frame(Species = BM$Species,
                                 Body_mass = BM$BM_class_scld)


### Hypsodonty Index
hypso <- read_xlsx("./Data/Traits/Species_Lists/Chinchilloidea_Hypsodonty_SpeciesList.xlsx")
hypso$Hypsodonty_category <- as.numeric(hypso$Hypsodonty_category)
  # Save the median
med_hyp <- median(hypso$Hypsodonty_category, na.rm = T)
transf_features_tbl$Hypsodonty <- c(med_hyp, 1)
  # Scale
hypso <- hypso %>% mutate(Hypsodonty_category_scld = (Hypsodonty_category - med_hyp))

  # Store HI
categorical_traits <- categorical_traits %>% 
  mutate(Hypsodonty = unlist(sapply(X = Species,
                             FUN = function(x){
                               return(hypso$Hypsodonty_category_scld[which(hypso$name == x)])
                               }
                             ))
         )

### Tropicality (+ pertenency to West Indies, see MacPhee 2011) ###
chinchi <- read_xlsx("./Data/OccDB_cleaned/ChinchilloideaOccurrences_cleaned.xlsx")

chinchi <- chinchi %>%
  filter(!is.na(sp_lvl_status)) %>% 
  select(accepted_name, sp_lvl_status, min_ma, max_ma, loc) %>% 
  mutate(min_ma = as.numeric(min_ma), max_ma = as.numeric(max_ma)) %>% 
  rename(Species = "accepted_name", Status = "sp_lvl_status", min_age = "min_ma", max_age = "max_ma")

# Remove occurrences associated with open nomenclature
true_sp <- sapply(X = chinchi$Species,
                  FUN = open_checkR)
chinchi <- chinchi[true_sp, ]

## Merge with simulated occurrences of extant species (we have traits for all of them) (see `1c-extant_Ts_sampling.R`)
extant_chinchi <- read.table("./Data/OccDB_cleaned/extant_taxa_with_no_fossils.txt", 
                             header = T)
extant_chinchi <- extant_chinchi %>% 
  mutate(loc = sapply(X = Species,
                      FUN = function(x){
                        if(x %in% c("Chinchilla_chinchilla", "Chinchilla_lanigera", "Lagidium_wolffsohni", "Lagidium_viscacia")){
                          return("E")
                        }
                        else{
                          return("T")
                        }
                      }))
chinchi_ext <- rbind(chinchi, extant_chinchi)

# Carribean taxa
caribbea <- c("Amblyrhiza_inundata", "Borikenomys_praecursor", 
              "Clidomys_osborni","Elasmodontomys_obliquus", "Quemisia_gravis")

# One-hot encoding for taxa both found under tropical and extratropical latitudes
categorical_traits <- categorical_traits %>% 
  mutate(Tropical = sapply(X = Species,
                           FUN = function(x){
                             loc <- chinchi_ext$loc[which(chinchi_ext$Species == x)]
                             if("T" %in% loc){
                               if(x %in% caribbea){
                                 return(0)
                               }
                               else{
                                 return(1)
                               }
                             }
                             else{
                               return(0)
                             }
                           }),
         Extratropical = sapply(X = Species,
                           FUN = function(x){
                             loc <- chinchi_ext$loc[which(chinchi_ext$Species == x)]
                             if("E" %in% loc){
                               if(x %in% caribbea){
                                 return(0)
                               }
                               else{
                                 return(1)
                               }
                             }
                             else{
                               return(0)
                             }
                           }),
         Caribbean = sapply(X = Species,
                            FUN = function(x){
                              if(x %in% caribbea){
                                return(1)
                              }
                              else{
                                return(0)
                              }
                            }))

### Save species-specific categorical traits as well as transform feature table for species we could have traits for ###
categorical_traits_WithData <- categorical_traits %>% 
  filter(!(is.na(Body_mass) | is.na(Hypsodonty))) # will filter out 16 taxa
write.table.lucas(categorical_traits_WithData, "./Data/BDNN_features_extended/Categorical_traits_NoNA.txt")
write.table.lucas(transf_features_tbl, "./Data/BDNN_features_extended/Backscale_NoNA.txt")


## Subset occurrences of only taxa we could have traits for
chinchi_WithTraits <- chinchi %>% 
  filter(Species %in% categorical_traits_WithData$Species) %>% 
  select(!(loc))

write.table.lucas(chinchi_WithTraits, 
                  "./Data/PyRate_inputs/Chinchilloidea_cleaned_WithTraits_EXTENDED_EXTANT.txt")
extract.ages("./Data/PyRate_inputs/Chinchilloidea_cleaned_WithTraits_EXTENDED_EXTANT.txt", 
             replicates = 20)

## Remove Caribbean taxa

# First remove "caribbean" state from categorical predictor table
# categorical_traits_WithData_NoCar <- categorical_traits_WithData %>% 
#   select(!(Caribbean)) %>% 
#   filter(!(Species %in% c("Amblyrhiza_inundata", "Elasmodontomys_obliquus", 
#                           "Quemisia_gravis", "Clidomys_osborni", "Borikenomys_praecursor")))
# write.table.lucas(categorical_traits_WithData_NoCar, "./Data/BDNN_features/Categorical_traits_NoNA_NOCAR.txt")
# Remove occurrences
# chinchi_WithTraits_EXT_NOCAR <- chinchi_WithTraits_EXT %>% 
#   filter(!(Species %in% c("Amblyrhiza_inundata", "Elasmodontomys_obliquus", 
#                           "Quemisia_gravis", "Clidomys_osborni", "Borikenomys_praecursor")))
# 
# write.table.lucas(chinchi_WithTraits_EXT_NOCAR, 
#                   "./Data/PyRate_inputs/Chinchilloidea_cleaned_WithTraits_EXTENDED_EXTANT_NOCAR.txt")
# extract.ages("./Data/PyRate_inputs/Chinchilloidea_cleaned_WithTraits_EXTENDED_EXTANT_NOCAR.txt",
#              replicates = 20)
