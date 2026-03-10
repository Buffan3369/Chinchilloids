################################################################################
# Title: 4-MBD_predictors.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Preprocess predictors for MBD analyses.
################################################################################


library(tidyverse)
source("./R/useful/helper_functions.R")

################################################################################
############################# 0.5 My time step #################################
################################################################################

## Regional South American temperature (Tardif et al. 2025) --------------------
temp <- read.table("./Data/MBD_predictors/SA_regional_temperatures_Tardif_2025.txt", header = T)
# Downscale to a 0.5My time step
selected_indices <- sapply(X = seq(0, 36, 0.5), FUN = select_closer, age_vect = temp$Time)
temp500k <- temp[selected_indices, c(1, 2)] # only retain MAT
temp500k$Time <- seq(0, 36, 0.5) # Harmonise time vector
colnames(temp500k) <- c("Time", "Temperature")
write.table.lucas(temp500k, "./Data/MBD_predictors/1-Palaeotemperature_500ky_step_Tardif.txt")
# Scale
temp500k <- temp500k %>% mutate(Temperature = scale(Temperature))
write.table.lucas(temp500k, "./Data/MBD_predictors_Scaled/1-Palaeotemperature_500ky_step_Tardif_SCALED.txt")
# Time stratify
  # Early
temp500k_early <- temp500k %>% filter(Time > 6)
write.table.lucas(temp500k_early, "./Data/MBD_predictors_Scaled/early/1-Palaeotemperature_500ky_step_Tardif_SCALED_early.txt")
  # Late
temp500k_late <- temp500k %>% filter(Time <= 6)
write.table.lucas(temp500k_late, "./Data/MBD_predictors_Scaled/late/1-Palaeotemperature_500ky_step_Tardif_SCALED_late.txt")


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

new_uplift <- new_uplift %>% filter(Age <= 36)
write.table.lucas(new_uplift, "./Data/MBD_predictors/2-Average_Andean_uplift_500ky_step.txt")
# Scale
new_uplift <- new_uplift %>% mutate(elev = scale(elev))
write.table.lucas(new_uplift, "./Data/MBD_predictors_Scaled/2-Average_Andean_uplift_500ky_step-SCALED.txt")
# Time-stratify
  # Early
new_uplift_early <- new_uplift %>% filter(Age > 6)
write.table.lucas(new_uplift_early, "./Data/MBD_predictors_Scaled/early/2-Average_Andean_uplift_500ky_step-SCALED_early.txt")
  # Late
new_uplift_late <- new_uplift %>% filter(Age <= 6)
write.table.lucas(new_uplift_late, "./Data/MBD_predictors_Scaled/late/2-Average_Andean_uplift_500ky_step-SCALED_late.txt")


## Global sea level (from Miller et al. 2020) ----------------------------------
sea_lvl <- read.table("../Chapter_1/data_2023/MBD/raw_environment_correlates/sea_level/Miller_2020_sea_level_data.txt",
                      sep = "\t",
                      header = TRUE)
sea_lvl <- sea_lvl %>% 
  mutate(age_calkaBP = sapply(X = sea_lvl$age_calkaBP, FUN = function(x){x/1000})) %>% 
  rename(age_MaBP = "age_calkaBP")
selected_indices <- sapply(X = seq(from = 0, to = 36, by = 0.5), FUN = select_closer, age_vect = sea_lvl$age_MaBP)
# dataframe
slvl <- data.frame(Age = seq(from = 0, to = 36, by = 0.5),
                   Sea_level = sea_lvl$sealevel[selected_indices])
write.table.lucas(x = slvl, file = "./Data/MBD_predictors/3-Sea_level_500ky_step.txt")
# Scale
slvl <- slvl %>% mutate(Sea_level = scale(Sea_level))
write.table.lucas(x = slvl, file = "./Data/MBD_predictors_Scaled/3-Sea_level_500ky_step_SCALED.txt")
# Time stratify
  # Early
slvl_early <- slvl %>% filter(Age > 6)
write.table.lucas(x = slvl_early, file = "./Data/MBD_predictors_Scaled/early/3-Sea_level_500ky_step_SCALED_early.txt")
  # Late
slvl_late <- slvl %>% filter(Age <= 6)
write.table.lucas(x = slvl_late, file = "./Data/MBD_predictors_Scaled/late/3-Sea_level_500ky_step_SCALED_late.txt")


################################################################################
############################ Natural time scale ################################
################################################################################

## Regional South American temperature (Tardif et al. 2025) --------------------
temp <- read.table("./Data/MBD_predictors/SA_regional_temperatures_Tardif_2025.txt", header = T)
# Filter out time frame and scale
temp_processed <- temp %>% 
  filter(Time <= 36) %>% 
  rename(Age = "Time", Temperature = "SAMMAT") %>% 
  mutate(Temperature = as.numeric(scale(Temperature))) %>% 
  select(all_of(c("Age", "Temperature")))
write.table.lucas(temp_processed, "./Data/MBD_predictors_scaled_unphased/1-Palaeotemperature_Tardif_SCALED.txt")

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
upl <- andes_av %>% 
  filter(Age <= 36) %>% 
  mutate(Mean_elev = as.numeric(scale(Mean_elev)))
write.table.lucas(upl, "./Data/MBD_predictors_scaled_unphased/2-Average_Andean_uplift_SCALED.txt")

## Global sea level (from Miller et al. 2020) ----------------------------------
sea_lvl <- read.table("../Chapter_1/data_2023/MBD/raw_environment_correlates/sea_level/Miller_2020_sea_level_data.txt",
                      sep = "\t",
                      header = TRUE)
sea_lvl <- sea_lvl %>% 
  mutate(age_calkaBP = sapply(X = sea_lvl$age_calkaBP, FUN = function(x){x/1000})) %>% 
  rename(Age = "age_calkaBP") %>% 
  filter(Age <= 36) %>% 
  mutate(sealevel = as.numeric(scale(sealevel))) %>% 
  select(all_of(c("Age", "sealevel")))
# dataframe
write.table.lucas(x = sea_lvl, file = "./Data/MBD_predictors_scaled_unphased/3-Sea_level_SCALED.txt")
