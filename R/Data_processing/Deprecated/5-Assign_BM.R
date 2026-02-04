################################################################################
# Title: 5-Assign_BM.R
# Author: Lucas Buffan
# E-mail: lucas.l.buffan@gmail.com
# Description: Assign body mass from dental proxies for species in our dataset.
################################################################################


library(tidyverse)
library(readxl)
source("./R/useful/helper_functions.R")

## Function to assess BM from dental measures (Boivin et al. 2024) -------------

# Coefficient of the OLS-obtained equations
coeff_tbl <- read_xlsx("./Data/Traits/Ressources/Boivin_etal_2024-ressources/BestModels_Coefficients_Boivin2024.xlsx")

# Core fucntion (nb. Body mass is estimated in grams)
BM_estimator <- function(structure = c("p4", "P4", "m1", "M1", "m2", "M2", "m3", "M3"),
                            LM, WM, # mesio-distal and labio-lingual measures of the cheek tooth
                            what = c("mean", "2.5%", "97.5%"), transform = T){
  # Select coefficients corresponding to the best model associated with the structure
  row_idx <- which(coeff_tbl$Structure == structure)
  alpha_L <- coeff_tbl$alpha_L[row_idx]
  alpha_W <- coeff_tbl$alpha_W[row_idx]
  beta <- coeff_tbl$beta[row_idx]
  # Confidence interval coeffs
  IC_L <- coeff_tbl$IC_L[row_idx]
  IC_W <- coeff_tbl$IC_W[row_idx]
  IC_beta <- coeff_tbl$IC_beta[row_idx]
  # If we choose to assess the mean body mass
  if(what == "mean"){
    Log_BM <- alpha_L*log10(LM)+alpha_W*log10(WM)+beta
  }
  # Else, if we are interested in the boundaries of the CI
  else if(what == "2.5%"){
    Log_BM <- (alpha_L-IC_L)*log10(LM)+(alpha_W-IC_W)*log10(WM)+(beta-IC_beta)
  }
  else if(what == "97.5%"){
    Log_BM <- (alpha_L+IC_L)*log10(LM)+(alpha_W+IC_W)*log10(WM)+(beta+IC_beta)
  }
  # What to return?
  rtn <- Log_BM
  if(transform){ # If set to False, remember to use the ratio estimator to further transform log body mass in unbiased body mass 
    RE <- coeff_tbl$RE[row_idx]
    # Pass to power 10
    rtn <- 10**Log_BM
    # Correct with the ratio estimator
    rtn <- rtn*RE
  }
  return(rtn)
}


## Apply to our dataset --------------------------------------------------------

# Open our dental measurments
dent_mes <- read_xlsx("./Data/Traits/Old/Dental_measures_Missing_Chinchi_M2.xlsx")

# Filter out taxa for which no data could be found
dent_mes <- dent_mes %>% 
  filter(!is.na(`Museum number`)) %>%
  filter(Structure != "OK")

# Numericise measures
dent_mes <- dent_mes %>% 
  mutate(L = sapply(X = L, FUN = as.numeric)) %>% 
  mutate(W = sapply(X = W, FUN = as.numeric))

grepMod <- function(pattern, x){
  a <- grep(pattern, x)
  if(length(a) == 0){
    return(0)
  }
  else{
    return(1)
  }
}

# Which proxy should we use?
struct_simplifier <- function(struct){
  # Whenever there's an M2, prioritise it
  if(grepMod("M2", struct) == 1){
    return("M2")
  }
  # Follow by the best proxies ranked by decreasing order
  else if(grepMod("M1", struct) == 1){
    return("M1")
  }
  else if(grepMod("m2", struct) == 1){
    return("m2")
  }
  else if(grepMod("m1", struct) == 1){
    return("m1")
  }
  else if(grepMod("P4", struct) == 1){
    return("P4")
  }
  else if(grepMod("p4", struct) == 1){
    return("p4")
  }
  else if(grepMod("M3", struct) == 1){
    return("M3")
  }
  else if(grepMod("m3", struct) == 1){
    return("m3")
  }
}

# Core function
assess_BM_tax <- function(taxon, what){
  # Structure(s) associated to the taxon
  subtbl <- dent_mes %>% 
    filter(Taxon == taxon) %>% 
    mutate(simpl_sturct = sapply(Structure, FUN = struct_simplifier))
  # BodyMass estimation
  subtbl$BM <- NA
  for(i in 1:nrow(subtbl)){
    subtbl$BM[i] <- BM_estimator(structure = subtbl$simpl_sturct[i],
                                 LM = subtbl$L[i],
                                 WM = subtbl$W[i],
                                 what = what)
  }
  return(mean(subtbl$BM, na.rm = T))
}

# Apply to all our taxa
tax <- unique(dent_mes$Taxon)
BM_tax <- sapply(X = tax, FUN = assess_BM_tax, what = "mean")
df_BM_merged <- data.frame(Taxon = tax,
                           BM = BM_tax)
row.names(df_BM_merged) <- 1:nrow(df_BM_merged)

## Merge with estimates produced for Phylogeny and categorise ------------------

BM_phylo <- read.table("./Data/Traits/Old/ChinchilloideaPhylo_BodyMass.txt")
colnames(BM_phylo) <- c("Taxon", "BM")

BM_combined <- rbind.data.frame(BM_phylo, df_BM_merged)
BM_combined <- BM_combined %>% 
  mutate(BM_class = sapply(BM, FUN = bm_reclass))

# Manually add data for Chinchilla chinchilla and Lagidium peruanum

BM_combined <- BM_combined %>% 
  add_row(Taxon = "Chinchilla_chinchilla", BM = 1250, BM_class = 2) %>% # between 1.1 and 1.4 kgs
  add_row(Taxon = "Lagidium_peruanum", BM = 1200, BM_class = 2) # between 1.1 and 1.4 kgs

# Save
saveRDS(BM_combined, "./Data/Traits/Old/ChinchilloideaCombined_BodyMass.RDS")
