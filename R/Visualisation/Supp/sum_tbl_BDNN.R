library(tidyverse)

################################################################################
############################ 1. Ranked predictors ##############################
################################################################################
## Initialise dfs --------------------------------------------------------------
path_to_tbl <- list.files(paste0("./Results/BDNN/BDNN_imputation_NoCar/Replicate_1/combined_logs"),
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
  path_to_tbl <- list.files(paste0("./Results/BDNN/BDNN_imputation_NoCar/Replicate_",
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

## Save ------------------------------------------------------------------------
saveRDS(sp_pred_infl, 
        "./Data/supp_tbl/BDNN_imputation_NoCar/BDNN_predictor_importance_sp_rate_NoCar.RDS")
saveRDS(ex_pred_infl, 
        "./Data/supp_tbl/BDNN_imputation_NoCar/BDNN_predictor_importance_ex_rate_NoCar.RDS")

################################################################################
###################### 2. Coefficients of rate variation #######################
################################################################################

CV <- read.csv("./Results/BDNN/BDNN_imputation_NoCar/Replicate_1/combined_logs/combined_10KEEP_coefficient_of_rate_variation.csv",
               header = T)
CV$replicate <- 1
for(i in 2:10){
  path_to_cv <- list.files(paste0("./Results/BDNN/BDNN_imputation_NoCar/Replicate_",
                                   i, "/combined_logs"),
                            pattern = "coefficient_of_rate_variation.csv",
                            full.names = T)
  cv <- read.csv(file = path_to_cv, header = T)
  cv$replicate <- i
  CV <- rbind.data.frame(CV, cv)
}

# Summarise CV for speciation rate
CV_sp <- CV %>% 
  filter(rate == "speciation") %>% 
  select(all_of(c("cv_empirical", "cv_expected", "replicate")))
CV_sp[nrow(CV_sp)+1, ] <- c(mean(CV_sp$cv_empirical), mean(CV_sp$cv_expected), "Total")
saveRDS(CV_sp, "./Data/supp_tbl/BDNN_imputation_NoCar/coeff_speciation_rate_variation_across_replicates_NoCar.RDS")
# Summarise CV for extinction rate
CV_ex <- CV %>% 
  filter(rate == "extinction") %>% 
  select(all_of(c("cv_empirical", "cv_expected", "replicate")))
CV_ex[nrow(CV_ex)+1, ] <- c(mean(CV_ex$cv_empirical), mean(CV_ex$cv_expected), "Total")
saveRDS(CV_ex, "./Data/supp_tbl/BDNN_imputation_NoCar/coeff_extinction_rate_variation_across_replicates_NoCar.RDS")


################################################################################
###### 3. Magnitude in extinction rate change across BM classes and lat  #######
################################################################################

FC_BM25 <- c() # Fold change between S and XL
FC_BM25_upr <- c() # Upper Credible Interval of the latter FC
FC_BM25_lwr <- c() # Lower CI

FC_ET <- c() # Same between tropical & extratropical
FC_ET_upr <- c()
FC_ET_lwr <- c()

for(i in 1:10){
  path_to_ex <- list.files(paste0("./Results/BDNN/BDNN_imputation_NoCar/Replicate_", i,
                                  "/combined_logs"), 
                           pattern = "ex_predictor_influence.csv",
                           full.names = T)
  ex_tbl <- read.csv(path_to_ex[[1]], header = T)
  # Increment BM Fold Change vectors
  FC_BM25 <- c(FC_BM25, ex_tbl$fold_change[which(ex_tbl$feature1 == "Body_mass" &
                                                   ex_tbl$feature1_state == "2_5")]) 
  FC_BM25_upr <- c(FC_BM25_upr, ex_tbl$fold_change_upr_CI[which(ex_tbl$feature1 == "Body_mass" &
                                                                ex_tbl$feature1_state == "2_5")]) 
  FC_BM25_lwr <- c(FC_BM25_lwr, ex_tbl$fold_change_lwr_CI[which(ex_tbl$feature1 == "Body_mass" &
                                                                ex_tbl$feature1_state == "2_5")]) 
  # Same for lat vectors
  FC_ET <- c(FC_ET, ex_tbl$fold_change[which(ex_tbl$feature1_state == "Tropical_Extratropical")])
  FC_ET_upr <- c(FC_ET_upr, ex_tbl$fold_change_upr_CI[which(ex_tbl$feature1_state == "Tropical_Extratropical")])
  FC_ET_lwr <- c(FC_ET_lwr, ex_tbl$fold_change_lwr_CI[which(ex_tbl$feature1_state == "Tropical_Extratropical")])
}
# Make data frames
FC_tbl_BM <- data.frame(Replicate = 1:10,
                        Fold_Change = as.numeric(FC_BM25),
                        Fold_Change_UprCI = as.numeric(FC_BM25_upr),
                        Fold_Change_LwrCI = as.numeric(FC_BM25_lwr))
FC_tbl_BM[nrow(FC_tbl_BM)+1, ] <- 
  c("Total", apply(X = FC_tbl_BM[, 2:ncol(FC_tbl_BM)], FUN = mean, MARGIN = 2))

FC_tbl_Lat <- data.frame(Replicate = 1:10, 
                         Fold_Change = as.numeric(FC_ET),
                         Fold_Change_UprCI = as.numeric(FC_ET_upr),
                         Fold_Change_LwrCI = as.numeric(FC_ET_lwr))
FC_tbl_Lat[nrow(FC_tbl_Lat)+1, ] <- 
  c("Total", apply(X = FC_tbl_Lat[, 2:ncol(FC_tbl_Lat)], FUN = mean, MARGIN = 2))
# Save
saveRDS(FC_tbl_BM, "./Data/supp_tbl/BDNN_imputation_NoCar/Fold_change_S_XL_across_replicates.RDS")
saveRDS(FC_tbl_Lat, "./Data/supp_tbl/BDNN_imputation_NoCar/Fold_change_Trop_Etrop_across_replicates.RDS")
