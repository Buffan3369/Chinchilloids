################################################################################
# Name: 4-RTT_Lat_BM_class.R
# Author: Lucas Buffan (Lucas.L.Buffan@gmail.com)
# Aim: Plot freq rate shifts across latitude and BM classes.
################################################################################

library(ggpubr)
library(hash)

## Useful tools and functions --------------------------------------------------
source("~/Documents/GitHub/CorsaiR/R/1-extract_param_from_PyRate_outputs.R")
source("~/Documents/GitHub/CorsaiR/R/2-plotting_facilities.R")
source("./R/useful/load_GTS.R")
source("./R/useful/helper_functions.R")

gsc1$abbr[which(gsc1$name == "Oligocene")] <- "Oligocene"
gsc1$abbr[which(gsc1$name == "Miocene")] <- "Miocene"

## Extract frs tables and plot -------------------------------------------------
palette <- hash("XS (<0.5kg)" = "#a6cee3", "S (<1kg)" = "#1f78b4", "M (<10kg)" = "#ff7f00",
                "L (<100kg)" = "#33a02c", "XL (<200kg)" = "#fb9a99", "XXL (>200kg)" = "#e31a1c")
plotlist <- list()
i <- 0

a <- keys(palette)
a <- factor(a, levels = c("XS (<0.5kg)", "S (<1kg)", "M (<10kg)", 
                          "L (<100kg)", "XL (<200kg)", "XXL (>200kg)"))
for(cat in levels(a)){
  c <- strsplit(cat, split = " ")[[1]]
  frs_tbl <- extract_histo_tbl(path = paste0("./Results/RJMCMC/species/6-BM_categories/", c[1], "/combined_logs/RTT_plots.r"))
  
  frs_plot <- freq_rate_shift(data = frs_tbl[[1]],
                              bf2 = frs_tbl[[2]],
                              bf6 = frs_tbl[[3]],
                              x_annots = 25,
                              y_lab_sp = "Freq. of rate shift",
                              y_lab_ex = NULL,
                              main = c(paste0("Speciation Rate (", c[1], ")"),
                                       paste0("Extinction Rate (", c[1], ")")),
                              x_breaks = seq(35, 5, -5),
                              x_limits = c(36.2, 0),
                              axis_labsize = 7.5,
                              tick_labsize = 5,
                              plot_titlesize = 10,
                              bf_labsize = 1.5,
                              col = c("#4c4cec", "#e34a33"),
                              fill = c(values(palette[cat]), values(palette[cat])),
                              y_limits = c(0, max(c(frs_tbl[[3]]+0.02,
                                                    max(frs_tbl[[1]][,1]+0.02), # max freq rate shift for speciation
                                                    max(frs_tbl[[1]][,2]+0.02)))), # same for extinction
                              several_gts = TRUE,
                              lwd = 0.5,
                              geoscale = gsc1,
                              geoscale2 = gsc4,
                              geoscale_height = unit(.5, "line"))
  idx <- which(levels(a) == cat)
  print(idx)
  plotlist[[idx+i]] <- frs_plot[[1]]
  i <- i+1
  plotlist[[idx+i]] <- frs_plot[[2]]
  }

full_plt <- ggarrange(plotlist = plotlist, ncol = 2, nrow = 6)
ggsave("./Figures/Supp/RTT_per_BM/freq_rate_shift_per_BM.pdf", plot = full_plt,
       height = 300, width = 120, units = "mm")

