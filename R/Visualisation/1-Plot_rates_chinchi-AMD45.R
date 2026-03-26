################################################################################
# Name: 1-Plot_rates_chinchi.R
# Author: Lucas Buffan (Lucas.L.Buffan@gmail.com)
# Aim: Plot diversification & preservation rates through time as estimated with
#      RJMCMC
################################################################################

library("hash")
library("ggpubr")
library("tidyverse")

## Source accessory functions for plotting -------------------------------------
source("~/Documents/GitHub/CorsaiR/R/1-extract_param_from_PyRate_outputs.R")
source("~/Documents/GitHub/CorsaiR/R/2-plotting_facilities.R")
source("./R/useful/load_GTS.R")

gsc1$max_age[which.max(gsc1$max_age)] <- 36.2
gsc1$abbr[which(gsc1$abbr == "Eo")] <- "E"
gsc1$abbr[which(gsc1$abbr == "Ol")] <- "Oligocene"
gsc1$abbr[which(gsc1$abbr == "Mio")] <- "Miocene"

gsc4$max_age[which.max(gsc4$max_age)] <- 36.2

for(lvl in c("genus", "species")){
  for(ana in c("1-Full", "3-NoCar", "3-Spatially_scaled")){
    if(lvl == "species" & ana == "3-Spatially_scaled"){
      next
    }
    if(lvl == "genus" & ana == "3-NoCar"){
      next
    }
    ## Diversification rates -----------------------------------------------------
    # Get diversification rates table
    path_to_rtt <- paste0("./Results/RJMCMC/AMD-45/", lvl, "/", ana, "/combined_logs/RTT_plots.r")
    rtt_all_in_one <- extract_rtt(path_to_rtt, ana = "RJMCMC")
    # Extend for plotting issue
    rtt_all_in_one[nrow(rtt_all_in_one)+1, ] <- c(36.2, rtt_all_in_one[nrow(rtt_all_in_one), c(2:ncol(rtt_all_in_one))])
    # Origination and Extinction rates plot
    sp_ex_all_in_one <- rtt_plot(data = rtt_all_in_one,
                                 type = "SpEx",
                                 stage_x_breaks = FALSE,
                                 manual_x_breaks = seq(0, 35, 5),
                                 x_lab = NULL,
                                 restrict_y = TRUE,
                                 restrict_thr = 0.9,
                                 y_limits=c(0, 0.9),
                                 y_breaks = seq(0, 0.8, 0.2),
                                 several_gts = TRUE,
                                 geoscale = gsc1,
                                 geoscale2 = gsc4,
                                 geoscale_height=unit(1, "line")) +
      annotate(geom = "rect", xmin = 27.82, xmax = 33.9, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
      annotate(geom = "rect", xmin = 15.97, xmax = 23.03, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
      annotate(geom = "rect", xmin = 11.63, xmax = 5.33, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
      annotate(geom = "rect", xmin = 0, xmax = 2.58, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0)
    
    # Net diversification rate plot
    net_div_all_in_one <- rtt_plot(data = rtt_all_in_one,
                                   type = "net",
                                   x_lab = NULL,
                                   stage_x_breaks = FALSE,
                                   manual_x_breaks = seq(0, 35, 5),
                                   restrict_y = TRUE,
                                   restrict_thr = 0.9,
                                   y_limits=c(-0.9, 0.9),
                                   y_breaks = seq(-0.4, 0.8, 0.2),
                                   several_gts = TRUE,
                                   geoscale = gsc1,
                                   geoscale2 = gsc4,
                                   geoscale_height=unit(1, "line")) +
      annotate(geom = "rect", xmin = 27.82, xmax = 33.9, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
      annotate(geom = "rect", xmin = 15.97, xmax = 23.03, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
      annotate(geom = "rect", xmin = 11.63, xmax = 5.33, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
      annotate(geom = "rect", xmin = 0, xmax = 2.58, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0)
    
    ## Lineages-through-time (LTT)------------------------------------------------
    # LTT table
    path_to_ltt <- list.files(paste0("./Results/RJMCMC/AMD-45/", lvl, "/", ana, "/LTT/"), pattern = "se_est_ltt.txt", full.names = TRUE)[1]
    ltt_df <- read.table(path_to_ltt, header = TRUE)
    ltt_df <- ltt_df %>%
      rename("Age" = time, "Diversity" = diversity, "min_Diversity" = m_div, "max_Diversity" = M_div)
    ltt_df[nrow(ltt_df)+1, ] <- c(36.2, rep(NA, 3)) # for plotting
    # LTT plot
    ltt.plot <- ltt_plot(ltt_df,
                         y_breaks = seq(0,(round(max(ltt_df$Diversity, na.rm = T), -1) + 5), 5),
                         y_limits = c(0,(round(max(ltt_df$Diversity, na.rm = T), -1) + 7)),
                         stage_x_breaks = FALSE,
                         manual_x_breaks = seq(0, 35, 5),
                         several_gts = TRUE,
                         geoscale = gsc1,
                         geoscale2 = gsc4,
                         geoscale_height=unit(1, "line")) +
      annotate(geom = "rect", xmin = 27.82, xmax = 33.9, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
      annotate(geom = "rect", xmin = 15.97, xmax = 23.03, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
      annotate(geom = "rect", xmin = 11.63, xmax = 5.33, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
      annotate(geom = "rect", xmin = 0, xmax = 2.58, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0)
    
    ## Preservation (q) rates ----------------------------------------------------
    # q-rates table
    path_to_q <- paste0("./Results/RJMCMC/AMD-45/", lvl, "/", ana, "/Q_SHIFTS/Parsed_Q_rates.txt")
    q.table <- read.table(path_to_q, header = TRUE)
    q.table <- q.table[-c(nrow(q.table)),] # remove Holocene preservation rates
    # q-rates plot
    Q_plot <- q_plot(q.table,
                     ltt_df,
                     stage_x_breaks = FALSE,
                     manual_x_breaks = seq(0, 35, 5),
                     y_breaks = seq(from = 0, to = round(max(q.table$max_HPD)), as.integer(round(max(q.table$max_HPD))/4)),
                     several_gts = TRUE,
                     geoscale = gsc1,
                     geoscale2 = gsc4,
                     geoscale_height = unit(1, "line")) +
      annotate(geom = "rect", xmin = 27.82, xmax = 33.9, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
      annotate(geom = "rect", xmin = 15.97, xmax = 23.03, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
      annotate(geom = "rect", xmin = 11.63, xmax = 5.33, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0) +
      annotate(geom = "rect", xmin = 0, xmax = 2.58, fill = "grey50", ymin = -Inf, ymax = Inf, alpha = 0.2, linewidth = 0)
    
    
    ## Combine all these plots and save the output -------------------------------
    p <- ggarrange(plotlist = list(sp_ex_all_in_one, net_div_all_in_one, ltt.plot, Q_plot),
                   nrow = 2, ncol = 2, labels = c("(A)", "(B)", "(C)", "(D)"), font.label = list(size = 22))
    #p <- comb_ltt_rtt(sp_ex_all_in_one, net_div_all_in_one, ltt.plot, Q_plot, n_plots = 4)
    
    ana_out <- strsplit(ana, split = "-")[[1]][2]
    out_path <- paste0("./Figures/recap_figures_RJMCMC/AMD-45/Chinchilloidea_", lvl, "_", ana_out, "_Recap_figure-AMD45.pdf")
    
    ggsave(out_path,
           plot = p,
           height = 350,
           width = 450,
           units = "mm")
    
    ## Frequency of rate shift ---------------------------------------------------
    frs_tbl <- extract_histo_tbl(path_to_rtt)
    plot_list_frs <- freq_rate_shift(data = frs_tbl[[1]],
                                     bf2 = frs_tbl[[2]],
                                     bf6 = frs_tbl[[3]],
                                     x_annots = 25,
                                     y_annot_bf2 = frs_tbl[[2]]+0.005,
                                     y_annot_bf6 = frs_tbl[[3]]+0.005,
                                     y_lab_sp = "Freq. of rate shift",
                                     y_lab_ex = NULL,
                                     x_breaks = seq(35, 5, -5),
                                     x_limits = c(36.2, 0),
                                     y_limits = c(0, max(c(frs_tbl[[3]]+0.02,
                                                           max(frs_tbl[[1]][,1]+0.02), # max freq rate shift for speciation
                                                           max(frs_tbl[[1]][,2]+0.02)))), # same for extinction
                                     y_breaks = seq(0, 0.15, 0.05),
                                     several_gts = TRUE,
                                     geoscale = gsc1,
                                     geoscale2 = gsc4,
                                     geoscale_height = unit(.75, "line"))
    frs_panel <- ggarrange(plotlist = plot_list_frs, ncol = 2, labels = c("(A)", "(B)"), 
                           widths = c(20.25/40, 19.75/40), hjust = c(-1, -0.2))
    out_pah_frs <- ggsave(paste0("./Figures/recap_figures_RJMCMC/AMD-45/Chinchilloidea_", lvl, "_", ana_out, "_frequency_of_rate_shift-AMD45.pdf"),
                          plot = frs_panel,
                          height = 140,
                          width = 250,
                          units = "mm")
  }
}


