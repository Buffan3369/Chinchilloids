################################################################################
# Name: 12-Violin_ADE.R
# Author: Lucas Buffan
# Contact: lucas.l.buffan@gmail.com
# Aim: Violin plot for the Weibull shape parameter
################################################################################

library(tidyverse)
library(ggpubr)

burnin <- 10

## Genus dataset ---------------------------------------------------------------
  # Early
pth_early_gen <- "./Results/ADE/genus/early/pyrate_mcmc_logs/"
log_list_early_gen <- list.files(pth_early_gen, pattern = "ADE_ADE_mcmc.log")
df_early_gen <- read.table(paste0(pth_early_gen, log_list_early_gen[1]), header = TRUE)
df_early_gen <- df_early_gen[(burnin+1):nrow(df_early_gen), c("it", "w_shape")]
for(file in log_list_early_gen[2:length(log_list_early_gen)]){
  tmp <- read.table(paste0(pth_early_gen, file), header = TRUE)
  df_early_gen <- rbind(df_early_gen, tmp[(burnin+1):nrow(tmp), c("it", "w_shape")])
}
df_early_gen$Phase <- "Early"
  # Late
pth_late_gen <- "./Results/ADE/genus/late/pyrate_mcmc_logs/"
log_list_late_gen <- list.files(pth_late_gen, pattern = "ADE_ADE_mcmc.log")
df_late_gen <- read.table(paste0(pth_late_gen, log_list_late_gen[1]), header = TRUE)
df_late_gen <- df_late_gen[(burnin+1):nrow(df_late_gen), c("it", "w_shape")]
for(file in log_list_late_gen[2:length(log_list_late_gen)]){
  tmp <- read.table(paste0(pth_late_gen, file), header = TRUE)
  df_late_gen <- rbind(df_late_gen, tmp[(burnin+1):nrow(tmp), c("it", "w_shape")])
}
df_late_gen$Phase <- "Late"


## Write and save recap table --------------------------------------------------
HPD <- function(distrib, lvl=.95){
  alpha = (1-lvl)/2
  q <- as.numeric(quantile(distrib, probs = c(alpha, 1-alpha)))
  return(paste0("[", round(q[1], digits = 5), "; ", round(q[2], digits = 5), "]"))
}

recap_tbl <- data.frame(Phase=NA, Median_estimate=NA, HPD95=NA, HPD90=NA)
recap_tbl[1,] <- c("Genus Early", round(quantile(df_early_gen$w_shape, probs=(0.5)), digits = 5), HPD(df_early_gen$w_shape, lvl = .95), HPD(df_early_gen$w_shape, lvl = .90))
recap_tbl[2,] <- c("Genus Late", round(quantile(df_late_gen$w_shape, probs=(0.5)), digits = 5), HPD(df_late_gen$w_shape, lvl = .95), HPD(df_late_gen$w_shape, lvl = .90))
#write.table(recap_tbl, "./figures/supp_figs/ADE/recap_tbl_w_shape.txt", row.names = F, sep = "\t", quote = F)

## Assemble and plot -----------------------------------------------------------
# Genus
full_gen <- rbind(df_early_gen[, 2:3], df_late_gen[, 2:3])
full_gen$x <- "w_shape"

violin_ADE_gen <- full_gen %>% 
  ggplot(mapping = aes(x = x, y = w_shape, colour = Phase)) +
  geom_violin(draw_quantiles = c(0.025, 0.5, 0.975), scale = "width", colour = "black", aes(fill = Phase), adjust = 1.5) +
  scale_fill_manual(values = c("#006d2c", "#0868ac")) +
  scale_y_continuous(breaks = c(-2, 0, 1, 2, 4)) +
  ggtitle("Genus") +
  geom_hline(yintercept = 1, linetype = "dashed", colour = "grey") +
  labs(y = "Weibull shape") +
  theme(axis.title.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.x = element_blank(),
        axis.title.y = element_text(size = 18),
        axis.text.y = element_text(size = 15),
        plot.title = element_text(hjust = 0.5, size = 18),
        panel.background = element_blank(),
        panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.5))

ggsave("./Figures/ADE/Weibull_shape_genus.png", plot = violin_ADE_gen,
       height = 150, width = 150, units = "mm")
