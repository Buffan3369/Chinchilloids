################################################################################
# Title: 4-MBD_predictors.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Preprocess predictors for MBD analyses.
################################################################################


library(tidyverse)
source("./R/useful/helper_functions.R")


## Regional South American temperature (Tardif et al. 2025) -------------------
temp <- read.table("./Data/MBD_predictors/SA_regional_temperatures_Tardif_2025.txt", header = T)
# Downscale to a 0.5My time step
selected_indices <- sapply(X = seq(0, 38, 0.5), FUN = select_closer, age_vect = temp$Time)
temp500k <- temp[selected_indices, c(1, 2)] # only retain MAT
temp500k$Time <- seq(0, 38, 0.5) # Harmonise time vector
colnames(temp500k) <- c("Time", "Temperature")
write.table.lucas(temp500k, "./Data/MBD_predictors/1-Palaeotemperature_500ky_step_Tardif.txt")
# Scale
temp500k <- temp500k %>% mutate(Temperature = scale(Temperature))
write.table.lucas(temp500k, "./Data/MBD_predictors_Scaled/1-Palaeotemperature_500ky_step_Tardif_SCALED.txt")

## Andean uplift (Boschman & Condamine 2022) -----------------------------------
andes <- read.table("../Chapter_1/data_2023/MBD/raw_environment_correlates/andean_uplift/Andes_mean_elevations_no_basins_ALL.txt",
                    header = T)
andes_av <- data.frame(Age = unique(andes$Age),
                       Mean_elev = sapply(X = unique(andes$Age),
                                          FUN = function(age){
                                            elev_age <- andes$Altitude[which(andes$Age == age)]
                                            return(mean(elev_age))
                                          })
)
# Interpolate to reach a 500ky step
interpol_av_el <- approx(x = andes_av$Age[1:2], y = andes_av$Mean_elev[1:2], n=3)$y
for(i in 2:nrow(andes_av)){
  interpol_av_el <- c(interpol_av_el,
                      approx(x = andes_av$Age[i:(i+1)], y = andes_av$Mean_elev[i:(i+1)], n=3)$y[-c(1)])
}
new_age <- seq(0, 80, 0.5)
new_uplift <- data.frame(Age = new_age[1:(length(new_age)-2)],
                         elev = interpol_av_el)
# # VISUAL CHECK
# par(mfrow = c(1,2))
# plot(x = andes_av$Age, andes_av$Mean_elev)
# plot(x = new_uplift$Age, new_uplift$elev)
# dev.off()
# # OK

new_uplift <- new_uplift %>% filter(Age <= 38)
write.table.lucas(new_uplift, "./Data/MBD_predictors/2-Average_Andean_uplift_500ky_step.txt")
# Scale
new_uplift <- new_uplift %>% mutate(elev = scale(elev))
write.table.lucas(new_uplift, "./Data/MBD_predictors_Scaled/2-Average_Andean_uplift_500ky_step-SCALED.txt")
  
## Global sea level (from Miller et al. 2020) ----------------------------------
sea_lvl <- read.table("../Chapter_1/data_2023/MBD/raw_environment_correlates/sea_level/Miller_2020_sea_level_data.txt",
                      sep = "\t",
                      header = TRUE)
sea_lvl <- sea_lvl %>% 
  mutate(age_calkaBP = sapply(X = sea_lvl$age_calkaBP, FUN = function(x){x/1000})) %>% 
  rename(age_MaBP = "age_calkaBP")
selected_indices <- sapply(X = seq(from = 0, to = 38, by = 0.5), FUN = select_closer, age_vect = sea_lvl$age_MaBP)
# dataframe
slvl <- data.frame(Age = seq(from = 0, to = 38, by = 0.5),
                   Sea_level = sea_lvl$sealevel[selected_indices])
write.table.lucas(x = slvl, file = "./Data/MBD_predictors/3-Sea_level_500ky_step.txt")
# Scale
slvl <- slvl %>% mutate(Sea_level = scale(Sea_level))
write.table.lucas(x = slvl, file = "./Data/MBD_predictors_Scaled/3-Sea_level_500ky_step_SCALED.txt")

## Diversity of Carnivorans (estimated with PyRate from occurrences compiled by Tarquini et al. 2022)
CarniDiv <- read.table("./Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/LTT/Carnivora_species_occ_Tarquini_10_Grj_KEEP_se_est_ltt.txt", header = T)
# Downscale so it matches the timescale (last 38 Myrs with a 0.5Myr step)
selected_div <- sapply(X = seq(0, 9.5, 0.5), FUN = select_closer, age_vect = CarniDiv$time)
CarniDiv_down <- CarniDiv[selected_div, ] %>% 
  select(time, diversity)
CarniDiv_down$time <- seq(0, 9.5, 0.5) # standardise
# Extend until 38 Ma
Missing <- data.frame(time = seq(10, 38, 0.5),
                      diversity = rep(0, 57))
CarniDiv_down <- rbind(CarniDiv_down, Missing)
# Scale
CarniDiv_down$diversity <- scale(CarniDiv_down$diversity)
# Save
write.table.lucas(CarniDiv_down, "./Data/MBD_predictors_Scaled/4-Carnivora_diversity.txt")

## Diversity of North American herbivores (same as before) ---------------------
NorHerbDiv <- read.table("./Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/LTT/Northern_herbivores_sp_occ_Tarquini_10_Grj_KEEP_se_est_ltt.txt", header = T)
# Downscale so it matches the timescale (last 38 Myrs with a 0.5Myr step)
selected_div <- sapply(X = seq(0, 4.5, 0.5), FUN = select_closer, age_vect = NorHerbDiv$time)
NorHerbDiv_down <- NorHerbDiv[selected_div, ] %>% 
  select(time, diversity)
NorHerbDiv_down$time <- seq(0, 4.5, 0.5) # standardise
# Extend until 38 Ma
Missing <- data.frame(time = seq(5, 38, 0.5),
                      diversity = rep(0, 67))
NorHerbDiv_down <- rbind(NorHerbDiv_down, Missing)
# Scale
NorHerbDiv_down$diversity <- scale(NorHerbDiv_down$diversity)
# Save
write.table.lucas(NorHerbDiv_down, "./Data/MBD_predictors_Scaled/5-Northern_herbivores_diversity.txt")
