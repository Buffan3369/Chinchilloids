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
  geom_violin(aes(fill = BM_category), width = .8) +
  scale_fill_manual(values = c("#fcbba1", "#fc9272", "#fb6a4a", "#ef3b2c", "#cb181d", "#99000d")) +
  stat_summary(fun.data = sum_violin, size = 0.3) + # `sum_violin` loaded from helper_functions.R
  annotate(geom = "segment", linetype = "dashed", x = 1, xend = 6, y = 1.65, yend = 1.65) +
  annotate(geom = "text", x = 3.5, y = 1.73, label = "FC=2.37") +
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
  labs(x = NULL, y = NULL) +
  scale_y_continuous(breaks = seq(0, 0.8, 0.2)) +
  annotate(geom = "segment", linetype = "dashed", x = 1, xend = 2, y = 0.8, yend = 0.8) +
  annotate(geom = "text", x = 1.5, y = 0.84, label = "FC=1.60") +
  theme(axis.line.y = element_line(colour = "black"), 
        panel.background = element_blank(),
        legend.position = "none")

## Andean uplift ---------------------------------------------------------------
line_upl_ex <- which(grepl(x = script, pattern = "xlab = 'Andean_uplift', ylab = 'extinction'"))[1]
script_upl <- script[1:line_upl_ex]

upl <- script_upl[grepl(x = script_upl, pattern = "tr=c")]
upl <- split_vector(upl[length(upl)]) # only retain last element 

ex_rate_tot <- script_upl[grepl(x = script_upl, pattern = "r=c")]
ex_rate <- split_vector(ex_rate_tot[length(ex_rate_tot)-2]) # 3rd-to-last element 
ex_rate_lwr <- split_vector(ex_rate_tot[length(ex_rate_tot)-1]) # second-to-last element
ex_rate_upr <- split_vector(ex_rate_tot[length(ex_rate_tot)]) # last element

ex_upl_df <- data.frame(uplift = upl, ex_rate = ex_rate, 
                        ex_rate_lwr = ex_rate_lwr, ex_rate_upr = ex_rate_upr)
upl_plt <- ex_upl_df %>% 
  ggplot(aes(x = uplift, y = ex_rate)) +
  geom_ribbon(aes(ymin = ex_rate_lwr, ymax = ex_rate_upr), fill = "#cb181d", alpha = 0.2) +
  geom_line(colour = "#cb181d") +
  scale_y_continuous(breaks = seq(0, 0.8, 0.2)) +
  labs(x = "Andean elevation (m)", y = "Extinction rate") +
  theme(axis.line = element_line(colour = "black"), 
        panel.background = element_blank())
  
## Self Diversity --------------------------------------------------------------
line_div_ex <- which(grepl(x = script,
                           pattern = "xlab = 'Self_diversity', ylab = 'extinction'"))[1]
script_div <- script[1:line_div_ex]

div <- script_div[grepl(x = script_div, pattern = "tr=c")]
div <- split_vector(div[length(div)]) # only retain last element 

ex_rate_div_tot <- script_div[grepl(x = script_div, pattern = "r=c")]
ex_rate_div <- split_vector(ex_rate_div_tot[length(ex_rate_div_tot)-2]) # 3rd-to-last element 
ex_rate_div_lwr <- split_vector(ex_rate_div_tot[length(ex_rate_div_tot)-1]) # second-to-last element
ex_rate_div_upr <- split_vector(ex_rate_div_tot[length(ex_rate_div_tot)]) # last element

ex_div_df <- data.frame(diversity = div, ex_rate = ex_rate_div, 
                        ex_rate_lwr = ex_rate_div_lwr, ex_rate_upr = ex_rate_div_upr)
div_plt <- ex_div_df %>% 
  ggplot(aes(x = diversity, y = ex_rate)) +
  geom_ribbon(aes(ymin = ex_rate_lwr, ymax = ex_rate_upr), fill = "#cb181d", alpha = 0.2) +
  geom_line(colour = "#cb181d") +
  scale_y_continuous(breaks = seq(0, 1, 0.2)) +
  labs(x = "Self diversity", y = NULL) +
  theme(axis.line = element_line(colour = "black"), 
        panel.background = element_blank())

totplt <- ggarrange(plotlist = list(bm_ext, lat_ext, upl_plt, div_plt),
                    labels = c("(A)", "(B)", "(C)", "(D)"), hjust = c(-0.5, 0.2, -0.5, 0.2))
ggsave("./Figures/Main/Drivers/BDNN_extinction_correlates.pdf", 
       plot = totplt, height = 200, width = 200, units = "mm")
