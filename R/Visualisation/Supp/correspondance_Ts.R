library(tidyverse)

source("./R/useful/helper_functions.R")

# Ages from Phylogeny
hpd_df <- read.table("./Data/supp_tbl/95pct_HPD_tbl-UPHAM2019.txt", header = T)
hpd_df[3, ] <- apply(X = hpd_df, FUN = function(x){mean(x)}, MARGIN = 2) # add HPD midpoint
row.names(hpd_df) <- c("x_min", "x_max", "x")

t_df <- data.frame(t(hpd_df))
t_df$species_name <- row.names(t_df)
# plot_df_x <- t_df %>%
#   pivot_longer(cols = !Species)

################################################################################
################################# OLD APPROACH #################################
################################################################################

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


################################################################################
################################# NEW APPROACH #################################
################################################################################

library(SpeciesAge)
library(ggpubr)

lamb <- 0.53
mu <- 0.44

t <- seq(0, 36, 0.1)
age_dens_upham <- sapply(X = t, FUN = ageDensity, lambda = lamb, mu = mu, rho = 1)
age_dens_carrillo <- sapply(X = t, FUN = ageDensity, lambda = lamb, mu = mu, rho = 6/8)
plot_df <- data.frame(age = t, dens_upham = age_dens_upham, dens_car = age_dens_carrillo)

pal <- c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3", "#ff7f00", "#e7298a", "#bf5b17")

# Upham et al. (2019)
hpd_upham <- read.table("./Data/supp_tbl/95pct_HPD_tbl-UPHAM2019.txt",
                        header = T)
t_hpd_upham <- data.frame(min = t(hpd_upham)[,1],
                          max = t(hpd_upham)[,2],
                          mid = (t(hpd_upham)[,1] + t(hpd_upham)[,2])/2,
                          Species = factor(colnames(hpd_upham), 
                                           levels = c("Chinchilla_lanigera", "Dinomys_branickii", "Lagidium_peruanum",
                                                      "Lagidium_viscacia", "Lagidium_wolffsohni", "Chinchilla_chinchilla",
                                                      "Lagidium_ahuacaense")),
                          y = sapply(X = rep(-0.02, 7),
                                     FUN = function(x){
                                       g <- rnorm(n = 1, mean = 0, sd = 0.01)
                                       while(x+g >= 0){g <- rnorm(n = 1, mean = 0, sd = 0.01)}
                                       return(x+g)
                                     }))

u_plot <- ggplot() + 
  scale_x_reverse() +
  geom_hline(yintercept = 0, linetype = "dashed", linewidth = 0.25) +
  geom_line(data = plot_df, aes(x = age, y = dens_upham), linewidth = 0.5) +
  geom_segment(data = t_hpd_upham, aes(x = min, xend = max, y = y, yend = y, colour = Species), linewidth = 0.35) +
  geom_point(data = t_hpd_upham, aes(x = mid, y = y, fill = Species), size = 0.7) +
  scale_colour_manual(values = pal) +
  ylim(c(-0.03, 0.32)) +
  annotate(geom = "text", label = "rho=1", size = 3, x = 34, y = 0.31, fontface = "bold") +
  labs(x = "Age (Ma)", y = "Density", title = "Upham et al. (2019)") +
  theme(panel.background = element_blank(),
        panel.border = element_rect(linewidth = .75, colour = "black", fill = NA),
        axis.text = element_text(size = 5),
        axis.title = element_text(size = 6.5),
        plot.title = element_text(size = 12, hjust = 0.5),
        legend.title = element_text(hjust = 0.5, size = 6),
        legend.text = element_text(size = 4),
        legend.key.size = unit(0.5, "cm"))

# Carrillo et al. (2026)
hpd_carrillo <- read.table("./Data/supp_tbl/95pct_HPD_tbl-CARRILLO2026.txt",
                           header = T)
t_hpd_carrillo <- data.frame(min = t(hpd_carrillo)[,1],
                             max = t(hpd_carrillo)[,2],
                             mid = (t(hpd_carrillo)[,1] + t(hpd_carrillo)[,2])/2,
                             Species = colnames(hpd_carrillo),
                             y = sapply(X = t_hpd_upham$y[-which(t_hpd_upham$Species %in% c("Chinchilla_chinchilla",
                                                                                            "Lagidium_ahuacaense"))],
                                        FUN = function(x){return(x)}))
c_plot <- ggplot() + 
  scale_x_reverse() +
  geom_hline(yintercept = 0, linetype = "dashed", linewidth = 0.25) +
  geom_line(data = plot_df, aes(x = age, y = dens_car), linewidth = 0.5) +
  geom_segment(data = t_hpd_carrillo, aes(x = min, xend = max, y = y, yend = y, colour = Species), linewidth = 0.35) +
  geom_point(data = t_hpd_carrillo, aes(x = mid, y = y, fill = Species), size = 0.7) +
  ylim(c(-0.03, 0.32)) +
  scale_colour_manual(values = pal) +
  annotate(geom = "text", label = "rho=6/8", fontface = "bold", size = 3, x = 33, y = 0.31) +
  labs(x = "Age (Ma)", y = NULL, title = "Carrillo et al. (2026)") +
  theme(panel.background = element_blank(),
        panel.border = element_rect(linewidth = .75, colour = "black", fill = NA),
        axis.text = element_text(size = 5),
        axis.title = element_text(size = 6.5),
        plot.title = element_text(size = 12, hjust = 0.5),
        legend.position = "none")


combined_plot <- ggarrange(u_plot, c_plot, ncol = 2, widths = c(4.7/8, 3.3/8), labels = c("(a)", "(b)"), font.label = list(size = 10))
ggsave("./Figures/Supp/ExtantSampling/ExpectedTsDensity_Upham_Carrillo.pdf", 
       plot = combined_plot, height = 100, width = 200, units = "mm")
