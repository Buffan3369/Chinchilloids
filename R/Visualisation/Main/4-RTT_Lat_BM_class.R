################################################################################
# Name: 4-RTT_Lat_BM_class.R
# Author: Lucas Buffan (Lucas.L.Buffan@gmail.com)
# Aim: Plot RTT across latitude and BM classes.
################################################################################

library(ggpubr)

source("~/Documents/GitHub/CorsaiR/R/1-extract_param_from_PyRate_outputs.R")
source("./R/useful/load_GTS.R")
source("./R/useful/helper_functions.R")

gsc1$abbr[which(gsc1$name == "Oligocene")] <- "Oligocene"
gsc1$abbr[which(gsc1$name == "Miocene")] <- "Miocene"

## Across Latitude -------------------------------------------------------------
rtt_trop <- extract_rtt(path = "./Results/RJMCMC/species/4-Tropical/combined_logs/RTT_plots.r", 
                       ana = "RJMCMC")
rtt_trop$lat <- "Tropical"

rtt_etrop <- extract_rtt(path = "./Results/RJMCMC/species/5-Extratropical/combined_logs/RTT_plots.r", 
                        ana = "RJMCMC")
rtt_etrop$lat <- "Extratropical"

RTT_lat <- rbind.data.frame(rtt_etrop, rtt_trop)
RTT_lat$lat <- factor(RTT_lat$lat, levels = c("Extratropical", "Tropical"))

sp_plot_lat <- RTT_lat %>% 
  ggplot(aes(x = time, y = sp_rate)) +
  geom_ribbon(aes(ymin = sp_minHPD, ymax = sp_maxHPD, fill = lat), alpha = 0.2) +
  geom_line(aes(colour = lat)) +
  scale_x_reverse() +
  coord_geo(pos = list("bottom", "bottom"), dat = list(gsc4, gsc1))

ex_plot_lat <- RTT_lat %>% 
  ggplot(aes(x = time, y = ex_rate)) +
  geom_ribbon(aes(ymin = ex_minHPD , ymax = ex_maxHPD, fill = lat), alpha = 0.2) +
  geom_line(aes(colour = lat)) +
  scale_x_reverse() +
  coord_geo(pos = list("bottom", "bottom"), dat = list(gsc4, gsc1))

ggarrange(plotlist = list(sp_plot_lat, ex_plot_lat), ncol = 2)

## Across Body Mass categories -------------------------------------------------
RTT_BM <- extract_rtt(path = "./Results/RJMCMC/species/6-BM_categories/XS/combined_logs/RTT_plots.r", 
                      ana = "RJMCMC")
RTT_BM$cat <- "XS (<0.5kg)"

for(cat in c("S (<1kg)", "M (<10kg)", "L (<100kg)", "XL (<200kg)", "XXL (>200kg)")){
  c <- strsplit(cat, split = " ")[[1]]
  rtt <- extract_rtt(path = paste0("./Results/RJMCMC/species/6-BM_categories/", c[1], "/combined_logs/RTT_plots.r"), 
                     ana = "RJMCMC")
  rtt$cat <- cat
  RTT_BM <- rbind.data.frame(RTT_BM, rtt)
 }

  # RTT plot
RTT_BM$cat <- factor(RTT_BM$cat, levels = c("XS (<0.5kg)", "S (<1kg)", "M (<10kg)", "L (<100kg)", "XL (<200kg)", "XXL (>200kg)"))
RTT_BM <- RTT_BM %>% rename(`Body Mass category` = "cat")

sp_plot <- RTT_BM %>% 
  ggplot(aes(x = time, y = sp_rate, fill = `Body Mass category`, colour = `Body Mass category`)) +
  geom_ribbon(aes(ymin = sp_minHPD, ymax = sp_maxHPD), alpha = 0.2, colour = "transparent") +
  geom_line() +
  scale_x_reverse(breaks = seq(0, 35, 5)) +
  scale_colour_manual(values = c("#a6cee3", "#1f78b4", "#ff7f00", "#33a02c", "#fb9a99", "#e31a1c")) +
  scale_fill_manual(values = c("#a6cee3", "#1f78b4", "#ff7f00", "#33a02c", "#fb9a99", "#e31a1c")) +
  scale_y_continuous(breaks = seq(0, 3, 0.25)) +
  ggtitle("Speciation Rate") +
  labs(x = "Time (Ma)", y = "Rate (event/lineage/My)") +
  theme_lucas(legend.title = element_text(hjust = 0.5)) +
  coord_geo(pos = list("bottom", "bottom"), dat = list(gsc4, gsc1), height = unit(0.75, "line"), size = list(2, 3))

ex_plot <- RTT_BM %>% ggplot(aes(x = time, y = ex_rate, fill = `Body Mass category`, colour = `Body Mass category`)) +
  geom_ribbon(aes(ymin = ex_minHPD, ymax = ex_maxHPD), alpha = 0.2, colour = "transparent") +
  geom_line() +
  scale_x_reverse(breaks = seq(0, 35, 5)) +
  scale_colour_manual(values = c("#a6cee3", "#1f78b4", "#ff7f00", "#33a02c", "#fb9a99", "#e31a1c")) +
  scale_fill_manual(values = c("#a6cee3", "#1f78b4", "#ff7f00", "#33a02c", "#fb9a99", "#e31a1c")) +
  scale_y_continuous(breaks = seq(0, 3, 0.25)) +
  ggtitle("Extinction Rate") +
  labs(x = "Time (Ma)", y = NULL) +
  theme_lucas(legend.position = "none") +
  coord_geo(pos = list("bottom", "bottom"), dat = list(gsc4, gsc1), height = unit(0.75, "line"), size = list(2, 3))


RTT_plot_BM <- ggarrange(plotlist = list(sp_plot, ex_plot, NULL), ncol = 3, widths = c(12.5/20, 8.5/20, 1/20), labels = c("A", "B"))
ggsave("./Figures/Supp/RTT_per_BM/RTT_plot_per_BM.pdf", height = 120, width = 300, units = "mm")
  
