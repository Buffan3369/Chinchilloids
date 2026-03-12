library(tidyverse)

## Initialise dfs --------------------------------------------------------------
path_to_tbl <- list.files(paste0("./Results/BDNN/BDNN_imputation/Replicate_1/combined_logs"),
                          pattern = "predictor_influence.csv",
                          full.names = T)
# Speciation
sp_pred_infl <- read.csv(path_to_tbl[[2]], header = T)
sp_pred_infl <- sp_pred_infl %>% distinct(feature1, rank)
# Extinciton
ex_pred_infl <- read.csv(path_to_tbl[[1]], header = T)
ex_pred_infl <- ex_pred_infl %>% distinct(feature1, rank)

## Loop across the remaining ones ----------------------------------------------
for(i in 2:10){
  path_to_tbl <- list.files(paste0("./Results/BDNN/BDNN_imputation/Replicate_",
                                   i, "/combined_logs"),
                            pattern = "predictor_influence.csv",
                            full.names = T)
  # Speciation
  tmp_sp <- read.csv(path_to_tbl[[2]], header = T)
  tmp_sp <- tmp_sp %>% distinct(feature1, rank)
  sp_pred_infl <- merge(sp_pred_infl, tmp_sp, by = "feature1")
  # Extinction
  tmp_ex <- read.csv(path_to_tbl[[1]], header = T)
  tmp_ex <- tmp_ex %>% distinct(feature1, rank)
  ex_pred_infl <- merge(ex_pred_infl, tmp_ex, by = "feature1")
}

colnames(sp_pred_infl) <- c("Predictor", paste0("Replicate_", 1:10))
colnames(ex_pred_infl) <- c("Predictor", paste0("Replicate_", 1:10))

## Assess and sort sum of the ranks --------------------------------------------
sp_pred_infl <- sp_pred_infl %>% 
  mutate(SumRank = apply(X = sp_pred_infl[, 2:11],
                         FUN = function(x){sum(x)},
                         MARGIN = 1)) %>% 
  mutate(OverallRank = rank(SumRank))

ex_pred_infl <- ex_pred_infl %>% 
  mutate(SumRank = apply(X = ex_pred_infl[, 2:11],
                         FUN = function(x){sum(x)},
                         MARGIN = 1)) %>%  
  mutate(OverallRank = rank(SumRank))
