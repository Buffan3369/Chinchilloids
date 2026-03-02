library(tidyverse)

source("./R/useful/helper_functions.R")

# Ages from Phylogeny
hpd_df <- read.table("./Data/supp_tbl/95pct_HPD_tbl.txt", header = T)
hpd_df[3, ] <- apply(X = hpd_df, FUN = function(x){mean(x)}, MARGIN = 2) # add HPD midpoint
row.names(hpd_df) <- c("x_min", "x_max", "x")

t_df <- data.frame(t(hpd_df))
t_df$species_name <- row.names(t_df)
# plot_df_x <- t_df %>%
#   pivot_longer(cols = !Species)

# Re-estimated ages
TL <- read.table("./Data/PyRate_inputs/Species/1-Chinchilloidea_sp_lvl_occ_EXTENDED_TaxonList.txt",
                 header = T)

TsTe_tbl <- read.table("./Results/RJMCMC/species/1-Full/LTT/1-Chinchilloidea_species_lvl_occ_10_Grj_KEEP_se_est.txt",
                       header = T)
TsTe_target <- TsTe_tbl %>% 
  mutate(species_name = TL$Species) %>% 
  filter(species_name %in% colnames(hpd_df)) %>% 
  select(species_name, matches("ts"))

TsTe_target <- TsTe_target %>% 
  mutate(y_min = apply(X = TsTe_target[, colnames(TsTe_target)[-1]],
                      FUN = function(x){quantile(x, probs = 0.025)},
                      MARGIN = 1),
         y_max = apply(X = TsTe_target[, colnames(TsTe_target)[-1]],
                      FUN = function(x){quantile(x, probs = 0.975)},
                      MARGIN = 1),
         y = apply(X = TsTe_target[, colnames(TsTe_target)[-1]],
                   FUN = function(x){mean(x)},
                   MARGIN = 1)) %>% 
  select(species_name, y_min, y_max, y)

# plot_df_y <- TsTe_target %>% 
#   pivot_longer(cols = !species_name)

# Plot
PLOT_DF <- merge(t_df, TsTe_target, by = "species_name")

corr_plot <- PLOT_DF %>%
  mutate(species_name = sapply(species_name, FUN = function(x){gsub("_", " ", x)})) %>% 
  ggplot(aes(x = x, y = y)) +
  # Add 1-1 line
  geom_line(data = data.frame(x_l = seq(0,25,1),
                              y_l = seq(0,25,1)),
            aes(x = x_l, y = y_l),
            linetype = 2) +
  # Add error bars and scatters
  geom_errorbar(aes(ymin = y_min, ymax = y_max)) +
  geom_errorbar(orientation = "y", aes(xmin = x_min, xmax = x_max)) + 
  geom_point(aes(fill = species_name), size = 1.5, shape = 21, colour = "black") +
  # Customise aesthetics
  scale_x_continuous(expand = c(0,0)) +
  scale_y_continuous(expand = c(0,0)) +
  labs(x = "Ts Phylogeny (Ma)", y = "Ts PyRate (Ma)", fill = "Species name") +
  theme_lucas(legend.title = element_text(size = 9),
              legend.text = element_text(size = 7))

ggsave("./Figures/Supp/corr_Ts_phylo_PyRate.pdf", plot = corr_plot, height = 9.5, width = 14, units = "cm")
