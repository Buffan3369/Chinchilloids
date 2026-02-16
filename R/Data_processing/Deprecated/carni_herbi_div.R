## Diversity of Carnivorans (estimated with PyRate from occurrences compiled by Tarquini et al. 2022)
CarniDiv <- read.table("./Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Carnivora/LTT/Carnivora_species_occ_Tarquini_10_Grj_KEEP_se_est_ltt.txt", header = T)
# Downscale so it matches the timescale (last 38 Myrs with a 0.5Myr step)
selected_div <- sapply(X = seq(0, 9.5, 0.5), FUN = select_closer, age_vect = CarniDiv$time)
CarniDiv_down <- CarniDiv[selected_div, ] %>% 
  select(time, diversity)
CarniDiv_down$time <- seq(0, 9.5, 0.5) # standardise
# Extend until 38 Ma
#Missing <- data.frame(time = seq(10, 38, 0.5),
#                      diversity = rep(0, 57))
#CarniDiv_down <- rbind(CarniDiv_down, Missing)
# Scale
CarniDiv_down$diversity <- scale(CarniDiv_down$diversity)
# Save
#write.table.lucas(CarniDiv_down, "./Data/MBD_predictors_Scaled/4-Carnivora_diversity.txt")
write.table.lucas(CarniDiv_down, "./Data/MBD_predictors_Scaled/4-Carnivora_diversity_unstandardised.txt") # without extending time frame until 38 Ma

## Diversity of North American herbivores (same as before) ---------------------
NorHerbDiv <- read.table("./Data/MBD_predictors/Tarquini_Carni_Herbi_North_Am/Northern_herbivores/LTT/Northern_herbivores_sp_occ_Tarquini_10_Grj_KEEP_se_est_ltt.txt", header = T)
# Downscale so it matches the timescale (last 38 Myrs with a 0.5Myr step)
selected_div <- sapply(X = seq(0, 4.5, 0.5), FUN = select_closer, age_vect = NorHerbDiv$time)
NorHerbDiv_down <- NorHerbDiv[selected_div, ] %>% 
  select(time, diversity)
NorHerbDiv_down$time <- seq(0, 4.5, 0.5) # standardise
# Extend until 38 Ma
#Missing <- data.frame(time = seq(5, 38, 0.5),
#                      diversity = rep(0, 67))
#NorHerbDiv_down <- rbind(NorHerbDiv_down, Missing)
# Scale
NorHerbDiv_down$diversity <- scale(NorHerbDiv_down$diversity)
# Save
#write.table.lucas(NorHerbDiv_down, "./Data/MBD_predictors_Scaled/5-Northern_herbivores_diversity.txt")
write.table.lucas(NorHerbDiv_down, "./Data/MBD_predictors_Scaled/5-Northern_herbivores_diversity_unstandardised.txt")
