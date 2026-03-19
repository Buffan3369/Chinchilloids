library(tidyverse)
library(hash)
library(ggpubr)
source("./R/useful/helper_functions.R")

artif_extd <- function(vect, target_length){
  if(length(vect) == target_length){
    return(vect)
  }
  else{
    diff <- target_length - length(vect)
    ext_vect <- c(vect, rep(NA, diff))
    return(ext_vect)
  }
}

BM_classes <- hash("1" = "XS",
                   "2" = "S",
                   "3" = "M",
                   "4" = "L",
                   "5" = "XL",
                   "6" = "XXL")

script <- readLines("./Results/BDNN/BDNN_imputation_NoCar/Replicate_8/combined_logs/combined_10KEEP_PDP.r",
                    n = 5000)

## Body mass violin ------------------------------------------------------------
trait <- "Body_mass"
# Index of the line indicating the end of the plot
line_idx <- which(script == paste0("title(main = '", trait, "')"))
# We cut the parts of the script written after the desired plot has been made
script_red <- script[1:line_idx[2]] # line_idx[1] : sp_rate, line_idx[2]: ex_rate, line_idx[3]: net_rate
# We extract the distributions of rates across categories
distribs <- script_red[grepl("vio_data=c", script_red)]
if(trait == "Body_mass"){
  distribs <- distribs[(length(distribs)-5):length(distribs)] # retain the last 6 distribs, corresponding to the 6 BM categories
}
# Create distrib df with harmonised lengths
ex_rate_distrib_df <- artif_extd(vect = as.numeric(split_vector(distribs[1])),
                                 target_length = 100)
for(i in 2:length(distribs)){
  ex_rate_distrib_df <- cbind(ex_rate_distrib_df,
                              artif_extd(vect = as.numeric(split_vector(distribs[i])),
                                         target_length = 100))
}
ex_rate_distrib_df <- as.data.frame(ex_rate_distrib_df)
colnames(ex_rate_distrib_df) <- values(BM_classes)

# Reformat for plotting
ex_rate_distrib_df <- ex_rate_distrib_df %>% 
  pivot_longer(cols = everything(), names_to = "BM_category", values_to = "Extinction_rate") %>% 
  mutate(BM_category = factor(BM_category, levels = c("XS", "S", "M", "L", "XL", "XXL")))

# Plot
bm_ext <- ex_rate_distrib_df %>% 
  ggplot(aes(x = BM_category, y = Extinction_rate)) +
  geom_violin(aes(fill = BM_category), width = .5) +
  scale_fill_manual(values = c("#fcbba1", "#fc9272", "#fb6a4a", "#ef3b2c", "#cb181d", "#99000d")) +
  stat_summary(fun.data = sum_violin) + # `sum_violin` loaded from helper_functions.R
  labs(x = NULL, y = "Extinction rate") +
  theme(axis.line.y = element_line(colour = "black"), 
        panel.background = element_blank(),
        legend.position = "none")

## Latitude violin -------------------------------------------------------------
trait <- "Tropicality"
# Index of the line indicating the end of the plot
line_idx <- which(script == paste0("title(main = '", trait, "')"))
# We cut the parts of the script written after the desired plot has been made
script_red <- script[1:line_idx[2]] # line_idx[1] : sp_rate, line_idx[2]: ex_rate, line_idx[3]: net_rate
# We extract the distributions of rates across categories
distribs <- script_red[grepl("vio_data=c", script_red)]
distribs <- distribs[(length(distribs)-1):length(distribs)] # retain the last 2 distribs, corresponding to the Tropical & Extratropical
# Create distrib df with harmonised lengths
ex_rate_distrib_df <- artif_extd(vect = as.numeric(split_vector(distribs[1])),
                                 target_length = 100)
ex_rate_distrib_df <- cbind(ex_rate_distrib_df,
                            artif_extd(vect = as.numeric(split_vector(distribs[2])),
                                       target_length = 100))

ex_rate_distrib_df <- as.data.frame(ex_rate_distrib_df)
colnames(ex_rate_distrib_df) <- c("Tropical", "Extratropical")

# Reformat for plotting
ex_rate_distrib_df <- ex_rate_distrib_df %>% 
  pivot_longer(cols = everything(), names_to = "Tropicality", values_to = "Extinction_rate") %>% 
  mutate(Tropicality = factor(Tropicality, levels = c("Tropical", "Extratropical")))

# Plot
lat_ext <- ex_rate_distrib_df %>% 
  ggplot(aes(x = Tropicality, y = Extinction_rate)) +
  geom_violin(aes(fill = Tropicality), width = .5) +
  scale_fill_manual(values = c("#fc9272", "#cb181d")) +
  stat_summary(fun.data = sum_violin) + # `sum_violin` loaded from helper_functions.R
  labs(x = NULL, y = "Extinction rate") +
  theme(axis.line.y = element_line(colour = "black"), 
        panel.background = element_blank(),
        legend.position = "none")


ggarrange(plotlist = list(bm_ext, lat_ext))
