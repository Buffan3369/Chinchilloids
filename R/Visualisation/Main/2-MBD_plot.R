################################################################################
# Name: 2-MBD_plots.r
# Author: Lucas Buffan
# Contact: lucas.l.buffan@gmail.com
# Aim: Script for MBD plot showing distributions of the correlation coeff.
################################################################################

## Source MBD accessory functions & covar names --------------------------------
source("./R/useful/MBD_accessory.R")

## Set strip labels for plots --------------------------------------------------
rate.labs <- c("Extinction rate", "Speciation rate")
names(rate.labs) <- c("Extinction", "Speciation")

dir <- "./Results/MBD/species_hsp0/"
int <- NA
tmp <- out_table_MBD(dir, interval = int, consider_w = F)
plot_df <- tmp[[1]]
signif_df <- tmp[[2]]
#plot
MBD_viol <- MBD.plot(PLOT_DF = plot_df,
                     SIGNIF_DF = signif_df,
                     x_breaks = 0:3,
                     x_labels = c(values(covar_idx)),
                     rate.labs = rate.labs,
                     time_facetting = FALSE)
ggsave(paste0("./Figures/Main/Drivers/MBD_species_complete_scaled_hsp0.pdf"),
       plot = MBD_viol,
       height = 150,
       width = 350,
       units = "mm")
